require 'rails_helper'
require 'support/gravity_helper'

describe 'Create Asset', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:submission) { Submission.create!(artist_id: 'andy-warhol', user_id: 'userid') }

  describe 'POST /assets' do
    it 'rejects unauthorized requests' do
      post '/api/assets', params: {
        gemini_token: 'gemini',
        submission_id: submission.id
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'rejects assets without a submission_id' do
      post '/api/assets', params: { gemini_token: 'gemini' }, headers: headers
      expect(response.status).to eq 404
    end

    it 'rejects assets without a gemini_token' do
      post '/api/assets', params: { submission_id: submission.id }, headers: headers
      expect(response.status).to eq 400
      expect(JSON.parse(response.body)['error']).to eq 'Parameter is required'
    end

    it 'creates an asset' do
      post '/api/assets', params: {
        submission_id: submission.id,
        gemini_token: 'gemini-token'
      }, headers: headers
      expect(response.status).to eq 201
      body = JSON.parse(response.body)
      expect(body['asset_type']).to eq('image')
      expect(body['submission_id']).to eq(submission.id)
      expect(body['image_urls']).to eq({})
    end
  end
end
