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

    it 'creates a submission' do
      expect do
        post '/api/submissions', params: {
          title: 'my sartwork',
          artist_id: 'artistid'
        }, headers: headers
      end.to change { Submission.count }.by(1)
    end

    it 'creates a submission with edition fields' do
      expect do
        post '/api/submissions', params: {
          title: 'my sartwork',
          artist_id: 'artistid',
          edition: true,
          edition_size: 100,
          edition_number: '23a'
        }, headers: headers

        expect(JSON.parse(response.body)['edition_size']).to eq 100
      end.to change { Submission.count }.by(1)
    end
  end
end
