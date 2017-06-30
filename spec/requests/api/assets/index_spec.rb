require 'rails_helper'
require 'support/gravity_helper'

describe 'Assets Index' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:submission) { Fabricate(:submission, artist_id: 'andy-warhol', user_id: 'userid') }

  describe 'GET /assets' do
    it 'rejects unauthorized requests' do
      get '/api/assets', params: {
        submission_id: submission.id
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'rejects requests without a submission_id' do
      get '/api/assets', headers: headers
      expect(response.status).to eq 404
    end

    it "rejects requests for someone else's submission" do
      submission = Fabricate(:submission, artist_id: 'andy-warhol', user_id: 'buster-bluth')
      asset = submission.assets.create!(asset_type: 'image', gemini_token: 'gemini', submission_id: submission.id)
      get "/api/assets/#{asset.id}", headers: headers
      expect(response.status).to eq 401
    end

    it 'returns the assets for a given submission' do
      Fabricate(:image, submission: submission, gemini_token: 'foo')
      Fabricate(:image, submission: submission, gemini_token: 'boo')
      get '/api/assets', params: {
        submission_id: submission.id
      }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 2
      expect(body.map { |a| a['gemini_token'] }).to include('foo', 'boo')
    end

    it 'returns only 10 assets for a given submission' do
      12.times { Fabricate(:image, submission: submission) }
      expect(submission.assets.count).to eq 12

      get '/api/assets', params: {
        submission_id: submission.id
      }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 10
    end
  end
end
