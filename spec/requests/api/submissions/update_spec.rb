# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'PUT /api/submissions' do
  let(:jwt_token) do
    payload = { aud: 'gravity', sub: 'userid' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  context 'with an unauthorized submission' do
    let(:headers) { { 'Authorization' => 'Bearer foo.bar.baz' } }

    it 'returns a 401' do
      put '/api/submissions/foo', headers: headers
      expect(response.status).to eq 401
    end
  end

  context 'with an invalid submission id' do
    it 'returns a 404 with an error' do
      put '/api/submissions/invalid', headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end
  end

  context 'with a submission id for another user' do
    let(:another_user) { Fabricate(:user, gravity_user_id: 'buster-bluth') }
    let(:submission) { Fabricate(:submission, user: another_user) }

    it "returns a 401" do
      put "/api/submissions/#{submission.id}", headers: headers
      expect(response.status).to eq 401
    end
  end

  context 'with a valid submission id' do
    let(:user) { Fabricate(:user, gravity_user_id: 'userid') }
    let(:submission) { Fabricate(:submission, user: user, artist_id: 'polly-painter') }

    it 'returns a 201 and updates that submission' do
      params = { artist_id: 'kara-walker' }
      put "/api/submissions/#{submission.id}", params: params, headers: headers
      expect(response.status).to eq 201
      body = JSON.parse(response.body)
      expect(body['id']).to eq submission.id
      expect(body['artist_id']).to eq 'kara-walker'
    end
  end

  context 'with a trusted app token' do
    let(:jwt_token) do
      payload = { aud: 'force', roles: 'trusted' }
      JWT.encode(payload, Convection.config.jwt_secret)
    end

    let(:submission) { Fabricate(:submission, user: user, artist_id: 'andy-warhol') }
    let(:params) { { artist_id: 'kara-walker', gravity_user_id: 'anonymous' } }

    context 'with a submission for the anonymous user' do
      let(:user) { User.anonymous }

      it 'returns a 201 and updates that submission' do
        put "/api/submissions/#{submission.id}", params: params, headers: headers
        expect(response.status).to eq 201
        body = JSON.parse(response.body)
        expect(body['id']).to eq submission.id
        expect(body['artist_id']).to eq 'kara-walker'
      end
    end

    context 'with a submission for another user' do
      let(:user) { Fabricate(:user) }

      it 'returns a 401' do
        put "/api/submissions/#{submission.id}", params: params, headers: headers
        expect(response.status).to eq 401
      end
    end
  end

  describe 'updating to submitted status' do
    context 'with all the valid fields' do
      before do
        @submission =
          Fabricate(
            :submission,
            user: Fabricate(:user, gravity_user_id: 'userid'),
            artist_id: 'artistid'
          )
      end

      it 'returns a 201 and sends receipt emails' do
        expect(NotificationService).to receive(:post_submission_event).once
        allow(Convection.config).to receive(:admin_email_address).and_return(
          'lucille@bluth.com'
        )
        stub_gravity_root
        stub_gravity_user
        stub_gravity_user_detail(email: 'michael@bluth.com')
        stub_gravity_artist

        Fabricate(:image, submission: @submission)

        put "/api/submissions/#{@submission.id}",
            params: { state: 'submitted' }, headers: headers

        expect(response.status).to eq 201
        expect(@submission.reload.receipt_sent_at).to_not be_nil
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        admin_email = emails.detect { |e| e.to.include?('lucille@bluth.com') }
        admin_copy = 'We have received the following submission from: Jon'
        expect(admin_email.html_part.body.to_s).to include(admin_copy)
        expect(admin_email.text_part.body.to_s).to include(admin_copy)

        user_email = emails.detect { |e| e.to.include?('michael@bluth.com') }
        user_copy = 'Thank you! We have received your submission.'
        expect(user_email.html_part.body.to_s).to include(user_copy)
        expect(user_email.text_part.body.to_s).to include(user_copy)
      end

      it 'does not resend notifications' do
        @submission.update!(receipt_sent_at: Time.now.utc)
        @submission.update!(admin_receipt_sent_at: Time.now.utc)

        put "/api/submissions/#{@submission.id}",
            params: { state: 'submitted' }, headers: headers
        expect(ActionMailer::Base.deliveries.length).to eq 0
      end
    end

    context 'without all the valid fields' do
      it 'returns a 400 with an error message' do
        submission =
          Fabricate(
            :submission,
            artist_id: 'andy-warhol',
            user: Fabricate(:user, gravity_user_id: 'userid'),
            title: nil
          )
        put "/api/submissions/#{submission.id}",
            params: { artist_id: 'kara-walker', state: 'submitted' },
            headers: headers

        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['error']).to eq(
          'Missing fields for submission.'
        )
        expect(submission.reload.artist_id).to eq 'andy-warhol'
      end
    end
  end
end
