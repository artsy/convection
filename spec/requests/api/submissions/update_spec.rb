require 'rails_helper'
require 'support/gravity_helper'

describe 'Update Submission' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'PUT /submissions' do
    it 'rejects unauthorized requests' do
      put '/api/submissions/foo', headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'returns an error if it cannot find the submission' do
      Fabricate(:submission, user_id: 'buster-bluth')
      put '/api/submissions/foo', headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end

    it "rejects requests for someone else's submission" do
      submission = Fabricate(:submission, user_id: 'buster-bluth')
      put "/api/submissions/#{submission.id}", headers: headers
      expect(response.status).to eq 401
    end

    it 'accepts requests for your own submission' do
      submission = Fabricate(:submission, artist_id: 'andy-warhol', user_id: 'userid')
      put "/api/submissions/#{submission.id}", params: {
        artist_id: 'kara-walker'
      }, headers: headers
      expect(response.status).to eq 201
      body = JSON.parse(response.body)
      expect(body['user_id']).to eq 'userid'
      expect(body['artist_id']).to eq 'kara-walker'
    end

    describe 'submitting' do
      describe 'with a valid submission' do
        before do
          @submission = Fabricate(:submission, user_id: 'userid', artist_id: 'artistid')
        end

        it 'sends a receipt when your state is updated to submitted' do
          expect(NotificationService).to receive(:post_submission_event).once
          allow(Convection.config).to receive(:admin_email_address).and_return('lucille@bluth.com')
          stub_gravity_root
          stub_gravity_user
          stub_gravity_user_detail(email: 'michael@bluth.com')
          stub_gravity_artist

          Fabricate(:image, submission: @submission)

          put "/api/submissions/#{@submission.id}", params: {
            state: 'submitted'
          }, headers: headers

          expect(response.status).to eq 201
          expect(@submission.reload.receipt_sent_at).to_not be_nil
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          admin_email = emails.detect { |e| e.to.include?('lucille@bluth.com') }
          admin_copy = 'We have received the following submission from: Jon'
          expect(admin_email.html_part.body.to_s).to include(admin_copy)
          expect(admin_email.text_part.body.to_s).to include(admin_copy)

          user_email = emails.detect { |e| e.to.include?('michael@bluth.com') }
          user_copy = 'Thank you for submitting your work to our'
          expect(user_email.html_part.body.to_s).to include(user_copy)
          expect(user_email.text_part.body.to_s).to include(user_copy)
        end

        it 'does not resend notifications' do
          @submission.update_attributes!(receipt_sent_at: Time.now.utc)
          @submission.update_attributes!(admin_receipt_sent_at: Time.now.utc)

          put "/api/submissions/#{@submission.id}", params: {
            state: 'submitted'
          }, headers: headers
          expect(ActionMailer::Base.deliveries.length).to eq 0
        end
      end

      it 'returns an error if you try to submit without all of the relevant fields' do
        submission = Fabricate(:submission,
          artist_id: 'andy-warhol',
          user_id: 'userid',
          title: nil)
        put "/api/submissions/#{submission.id}", params: {
          artist_id: 'kara-walker',
          state: 'submitted'
        }, headers: headers

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['error']).to eq('Missing fields for submission.')
        expect(submission.reload.artist_id).to eq 'andy-warhol'
      end
    end
  end
end
