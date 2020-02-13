# frozen_string_literal: true

require 'rails_helper'

describe 'Query Submissions With Graphql' do
  let(:admin_jwt_token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'admin' },
      Convection.config.jwt_secret
    )
  end
  let(:user_jwt_token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'user' },
      Convection.config.jwt_secret
    )
  end
  let(:headers) { { 'Authorization' => "Bearer #{admin_jwt_token}" } }
  let(:submission) do
    Fabricate(:submission, artist_id: 'abbas-kiarostami', title: 'rain')
  end
  let!(:submission2) do
    Fabricate(:submission, artist_id: 'andy-warhol', title: 'no-rain')
  end
  let(:asset) { Fabricate(:asset, submission: submission) }

  let(:query_submissions) do
    <<-GRAPHQL
    query {
      submissions(ids: ["#{submission.id}", "#{submission2.id}", "random"]) {
        edges {
          node {
            id,
            artist_id,
            title
          }
        }
      }
    }
    GRAPHQL
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql',
           params: { query: query_submissions },
           headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submissions']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access arguments: ids"
    end

    it 'throws an error if a user tries to access' do
      post '/api/graphql',
           params: { query: query_submissions },
           headers: { 'Authorization' => "Bearer #{user_jwt_token}" }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submissions']).to eq nil
      expect(body['errors'][0]['message']).to eq "Can't access arguments: ids"
    end

    it 'finds two existing submissions' do
      post '/api/graphql',
           params: { query: query_submissions }, headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['submissions']['edges'].count).to eq 2
    end
  end
end
