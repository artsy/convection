require 'rails_helper'

describe 'Create Submission With Graphql' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid', roles: 'user' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  let(:create_mutation) do
    <<-graphql
    mutation {
      createSubmission(submission: { artist_id: "andy", title: "soup" }){
        id,
        title
      }
    }
    graphql
  end

  let(:create_mutation_no_artist_id) do
    <<-graphql
    mutation {
      createSubmission(submission: { title: "soup" }){
        id,
        title
      }
    }
    graphql
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql', params: {
        query: create_mutation
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['createSubmission']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access createSubmission"
    end

    it 'rejects when missing artist_id' do
      post '/api/graphql', params: { query: create_mutation_no_artist_id }, headers: headers
      expect(response.status).to eq 200
    end

    it 'creates a submission' do
      expect do
        post '/api/graphql', params: {
          query: create_mutation
        }, headers: headers
        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        expect(body['data']['createSubmission']['id']).not_to be_nil
        expect(body['data']['createSubmission']['title']).to eq 'soup'
      end.to change(Submission, :count).by(1)
    end
  end
end
