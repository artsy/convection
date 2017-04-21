require 'rails_helper'
require 'support/api_helper'
require 'support/gravity_helper'

describe 'Create Submission', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'POST /submissions' do
    it 'rejects unauthorized submissions' do
      post '/api/submissions', params: {
        artist_id: 'artistid'
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'rejects submissions without an artist_id' do
      post '/api/submissions', params: {}, headers: headers
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['error']).to eq 'Parameter is required'
    end

    it 'creates a submission and sends an email' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist

      post '/api/submissions', params: {
        title: 'my artwork',
        artist_id: 'artistid'
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
  end
end
