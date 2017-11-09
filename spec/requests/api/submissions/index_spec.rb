require 'rails_helper'
require 'support/gravity_helper'

describe 'Show Submission' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe 'GET /submissions' do
    it 'rejects unauthorized requests' do
      get '/api/submissions', headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it "doesn't return other people's submissions" do
      Fabricate(:submission, user_id: 'buster-bluth')
      get '/api/submissions', headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body).to eq []
    end

    it 'returns your own submissions' do
      submission = Fabricate(:submission, user_id: 'userid')
      Fabricate(:submission, user_id: 'anotherid')

      get '/api/submissions', headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.length).to eq 1
      expect(body[0]['id']).to eq submission.id
    end

    it 'handles pagination correctly with your submissions' do
      submission = Fabricate(:submission, user_id: 'userid')
      Fabricate(:submission, user_id: 'userid')
      Fabricate(:submission, user_id: 'userid')

      get '/api/submissions', headers: headers, params: { page: 3, size: 1 }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body.first['id']).to eq submission.id
    end
  end
end
