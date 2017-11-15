require 'rails_helper'

describe 'Query Submissions With Graphql' do
  let(:admin_jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid', roles: 'admin' }, Convection.config.jwt_secret) }
  let(:user_jwt_token) { JWT.encode({ aud: 'gravity', sub: 'userid', roles: 'user' }, Convection.config.jwt_secret) }
  let(:headers) { { 'Authorization' => "Bearer #{admin_jwt_token}" } }
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
    it 'does not return the user_id if there is no user' do
      introspection_query = <<-graphql
        query {
          __type(name: "Submission") {
            name
            fields {
              name
            }
          }
        }
      graphql
      post '/api/graphql', params: {
        query: introspection_query
      }
      expect(JSON.parse(response.body)['data']['__type']['fields'].map { |f| f['name'] }).to_not include('user_id')
      expect(response.status).to eq 200
    end

    it 'includes the user_id param if there is a user present' do
      introspection_query = <<-graphql
        query {
          __type(name: "Submission") {
            name
            fields {
              name
            }
          }
        }
      graphql
      post '/api/graphql', params: {
        query: introspection_query
      }, headers: headers
      expect(JSON.parse(response.body)['data']['__type']['fields'].map { |f| f['name'] }).to include('user_id')
      expect(response.status).to eq 200
    end

    it 'finds two existing submissions' do
      post '/api/graphql', params: {
        query: query_submissions
      }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submission'].count).to eq 2
    end

    it 'throws an error if a user tries to access' do
      post '/api/graphql', params: {
        query: query_submissions
      }, headers: { 'Authorization' => "Bearer #{user_jwt_token}" }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submission']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access submission"
    end
  end
end
