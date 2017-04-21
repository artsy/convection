require 'rails_helper'
require 'support/api_helper'
require 'support/gravity_helper'

describe 'Update Submission', type: :request do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'PUT /submissions' do
    it 'rejects unauthorized requests' do
      put '/api/submissions', params: {
        submission_id: 'foo'
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'returns an error if it cannot find the submission' do
      Submission.create!(artist_id: 'andy-warhol', user_id: 'buster-bluth')
      put '/api/submissions', params: {
        submission_id: 'bloop'
      }, headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['error']).to eq 'Submission Not Found'
    end

    it "rejects requests for someone else's submission" do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'buster-bluth')
      put '/api/submissions', params: {
        submission_id: submission.id
      }, headers: headers
      expect(response.status).to eq 401
    end

    it 'accepts requests for your own submission' do
      submission = Submission.create!(artist_id: 'andy-warhol', user_id: 'userid')
      put '/api/submissions', params: {
        submission_id: submission.id,
        artist_id: 'kara-walker'
      }, headers: headers
      expect(response.status).to eq 201
      body = JSON.parse(response.body)
      expect(body['user_id']).to eq 'userid'
      expect(body['artist_id']).to eq 'kara-walker'
    end
  end
end
