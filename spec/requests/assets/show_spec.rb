require 'rails_helper'
require 'support/gravity_helper'

describe 'Show Asset', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /assets/:id' do
    it 'rejects unauthorized requests' do
      get '/api/assets/foo', headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'returns an error if it cannot find the asset' do
      Asset.create!(asset_type: 'image', gemini_token: 'gemini')
      get '/api/assets/foo', headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Not Found'
    end

    it "rejects requests for someone else's submission" do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'buster-bluth')
      asset = Asset.create!(asset_type: 'image', gemini_token: 'gemini', submission_id: submission.id)
      get "/api/assets/#{asset.id}", headers: headers
      expect(response.status).to eq 401
    end

    it 'accepts requests for your own submission' do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'userid')
      asset = Asset.create!(asset_type: 'image', gemini_token: 'gemini', submission_id: submission.id)
      get "/api/assets/#{asset.id}", headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['submission_id']).to eq submission.id
      expect(body['id']).to eq asset.id
    end
  end
end
