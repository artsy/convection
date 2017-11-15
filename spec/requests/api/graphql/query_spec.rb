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
      expect(JSON.parse(response.body)['data']['__type']['fields'].map{|f| f['name']}).to_not include('user_id')
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
      expect(JSON.parse(response.body)['data']['__type']['fields'].map{|f| f['name']}).to include('user_id')
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
  end
end
