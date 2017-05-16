require 'rails_helper'
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
      submissions_count = Submission.count
      post '/api/submissions', params: {
        title: 'my sartwork',
        artist_id: 'artistid'
      }, headers: headers

      expect(response.status).to eq 201
      expect(Submission.count).to eq(submissions_count + 1)
    end
  end
end
