require 'rails_helper'
require 'support/gravity_helper'

describe 'Update Submission', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'PUT /submissions' do
    it 'rejects unauthorized requests' do
      put '/api/submissions/foo', headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'returns an error if it cannot find the submission' do
      Submission.create!(artist_id: 'andy-warhol', user_id: 'buster-bluth')
      put '/api/submissions/foo', headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end

    it "rejects requests for someone else's submission" do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'buster-bluth')
      put "/api/submissions/#{submission.id}", headers: headers
      expect(response.status).to eq 401
    end

    it 'accepts requests for your own submission' do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'userid')
      put "/api/submissions/#{submission.id}", params: {
        artist_id: 'kara-walker'
      }, headers: headers
      expect(response.status).to eq 201
      body = JSON.parse(response.body)
      expect(body['user_id']).to eq 'userid'
      expect(body['artist_id']).to eq 'kara-walker'
    end

    describe 'submitting your submission' do
      it 'sends a receipt when your status is updated to submitted' do
        stub_gravity_root
        stub_gravity_user
        stub_gravity_user_detail(email: 'michael@bluth.com')
        stub_gravity_artist

        submission = Submission.create!(
          artist_id: 'artistid',
          user_id: 'userid',
          title: 'My Artwork',
          medium: 'painting',
          year: '1992',
          height: '12',
          width: '14',
          dimensions_metric: 'in',
          location_city: 'New York'
        )
        put "/api/submissions/#{submission.id}", params: {
          status: 'submitted'
        }, headers: headers

        expect(response.status).to eq 201
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        admin_email = emails.detect { |e| e.to.include?('specialist@artsy.net') }
        admin_copy = 'We have received the following submission from: Jon Jonson'
        expect(admin_email.html_part.body.to_s).to include(admin_copy)
        expect(admin_email.text_part.body.to_s).to include(admin_copy)

        user_email = emails.detect { |e| e.to.include?('michael@bluth.com') }
        user_copy = 'Thank you for submitting a consignment with Artsy.'
        expect(user_email.html_part.body.to_s).to include(user_copy)
        expect(user_email.text_part.body.to_s).to include(user_copy)
      end

      it 'returns an error if you try to submit without all of the relevant fields' do
        submission = Submission.create!(
          artist_id: 'andy-warhol',
          user_id: 'userid'
        )
        put "/api/submissions/#{submission.id}", params: {
          status: 'submitted'
        }, headers: headers

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['error']).to eq('Missing fields for submission.')
      end
    end
  end
end
