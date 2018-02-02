require 'rails_helper'

describe 'Update Submission With Graphql' do
  let(:jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid', roles: 'user' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }
  let(:submission) do
    Fabricate(:submission, artist_id: 'abbas-kiarostami', title: 'rain', user: Fabricate(:user, gravity_user_id: 'userid'))
  end

  let(:update_mutation) do
    <<-GRAPHQL
    mutation {
      updateSubmission(submission: { id: #{submission.id}, artist_id: "andy-warhol", title: "soup" }){
        id,
        artist_id,
        title
      }
    }
    GRAPHQL
  end

  let(:update_mutation_random_id) do
    <<-GRAPHQL
    mutation {
      updateSubmission(submission: { id: 999999, artist_id: "andy-warhol", title: "soup" }){
        id,
        title
      }
    }
    GRAPHQL
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql', params: {
        query: update_mutation
      }, headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['updateSubmission']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access updateSubmission"
    end

    it 'rejects requests without and app token' do
      user_token = JWT.encode({ sub: 'userid', roles: 'user' }, Convection.config.jwt_secret)
      post '/api/graphql', params: {
        query: update_mutation
      }, headers: { 'Authorization' => "Bearer #{user_token}" }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['updateSubmission']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access updateSubmission"
    end

    it 'rejects requests to update a submission that you do not own' do
      another_token = JWT.encode({ aud: 'app', sub: 'userid2', roles: 'user' }, Convection.config.jwt_secret)
      post '/api/graphql', params: {
        query: update_mutation
      }, headers: { 'Authorization' => "Bearer #{another_token}" }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['updateSubmission']).to eq nil
      expect(body['errors'][0]['message']).to eq 'Submission Not Found'
    end

    it 'errors for unknown submission id' do
      post '/api/graphql', params: { query: update_mutation_random_id }, headers: headers
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['errors'].first['message']).to eq 'Submission from ID Not Found'
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
