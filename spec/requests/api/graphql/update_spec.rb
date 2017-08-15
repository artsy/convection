require 'rails_helper'

describe 'Update Submission With Graphql' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:submission) { Fabricate(:submission, artist_id: 'abbas-kiarostami', title: 'rain') }

  let(:update_mutation) do
    <<-graphql
    mutation {
      updateSubmission(submission: { id: #{submission.id}, artist_id: "andy-warhol", title: "soup" }){
        id,
        artist_id,
        title
      }
    }
    graphql
  end

  let(:update_mutation_random_id) do
    <<-graphql
    mutation {
      updateSubmission(submission: { id: 999999, artist_id: "andy-warhol", title: "soup" }){
        id,
        title
      }
    }
    graphql
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql', params: {
        query: update_mutation
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 401
    end

    it 'errors for unkown submission id' do
      post '/api/graphql', params: { query: update_mutation_random_id }, headers: headers
      expect(response.status).to eq 404
    end

    it 'updates the submission' do
      post '/api/graphql', params: {
        query: update_mutation
      }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['updateSubmission']['id'].to_i).to eq submission.id
      expect(body['data']['updateSubmission']['title']).to eq 'soup'
      expect(body['data']['updateSubmission']['artist_id']).to eq 'andy-warhol'
    end
  end
end
