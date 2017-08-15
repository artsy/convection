require 'rails_helper'

describe 'Query Submissions With Graphql' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:submission) { Fabricate(:submission, artist_id: 'abbas-kiarostami', title: 'rain') }
  let!(:submission2) { Fabricate(:submission, artist_id: 'andy-warhol', title: 'no-rain') }
  let(:asset) { Fabricate(:asset, submission: submission) }

  let(:query_submissions) do
    <<-graphql
    query {
      submission(ids: ["#{submission.id}", "#{submission2.id}", "random"]) {
        id,
        artist_id,
        title
      }
    }
    graphql
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql', params: {
        query: query_submissions
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'finds two existing submissions' do
      post '/api/graphql', params: {
        query: query_submissions
      }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submission'].count).to eq 2
    end
  end
end
