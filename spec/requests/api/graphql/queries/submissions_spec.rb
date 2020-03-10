# frozen_string_literal: true

require 'rails_helper'

describe 'submissions query' do
  let(:submission) { Fabricate :submission }

  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'admin' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:query_inputs) { "ids: [\"#{submission.id}\"]" }

  let(:query) do
    <<-GRAPHQL
    query {
      submissions(#{query_inputs}) {
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

  describe 'invalid requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access arguments: ids"
      end
    end

    context 'with a request from a regular user' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access arguments: ids"
      end
    end
  end

  describe 'valid requests' do
    context 'with valid submission ids' do
      it 'returns those submissions' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1
      end
    end

    context 'with some valid and some invalid submission ids' do
      let(:submission2) { Fabricate :submission }

      let(:query_inputs) do
        "ids: [\"#{submission.id}\", \"#{submission2.id}\", \"invalid\"]"
      end

      it 'ignores that invalid submission ids and returns the known ones' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 2
      end
    end
  end
end
