# frozen_string_literal: true

require 'rails_helper'

describe 'submissions query' do
  let!(:submission) { Fabricate :submission }

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
            artistId,
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

    context 'with a user' do
      let!(:submission2) { Fabricate :submission }

      let(:query_inputs) { "userId: [\"#{submission.user.id}\", \"invalid\"]" }

      it 'returns only the submissions for that user' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1
      end
    end

    context 'with a request from a partner' do
      let(:token) do
        payload = { aud: 'gravity', sub: 'userid', roles: 'partner' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      let(:query) do
        <<-GRAPHQL
        query {
          submissions {
            edges {
              node {
                id,
                artistId,
                title
              }
            }
          }
        }
        GRAPHQL
      end

      it 'returns all submissions' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1
      end
    end

    context 'when asking for only available submissions' do
      let!(:submitted_submission) { Fabricate :submission, state: 'submitted' }
      let!(:approved_submission) { Fabricate :submission, state: 'approved' }

      let(:partner_submission) { Fabricate :partner_submission }

      let!(:consigned_submission) do
        Fabricate :submission,
                  state: 'approved',
                  consigned_partner_submission_id: partner_submission.id
      end

      let(:query_inputs) { 'available: true' }

      it 'returns only the available submissions' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1

        ids = submissions_response['edges'].map { |edge| edge['node']['id'] }
        expect(ids).to eq [approved_submission.id.to_s]
      end
    end

    context 'with an asset that has image urls' do
      let(:image_urls) do
        {
          'large' => 'http://wwww.example.com/large.jpg',
          'medium' => 'http://wwww.example.com/medium.jpg',
          'square' => 'http://wwww.example.com/square.jpg',
          'thumbnail' => 'http://wwww.example.com/thumbnail.jpg'
        }
      end

      let!(:asset) do
        Fabricate :image, submission: submission, image_urls: image_urls
      end

      let(:query) do
        <<-GRAPHQL
        query {
          submissions(#{query_inputs}) {
            edges {
              node {
                assets {
                  imageUrls
                }
              }
            }
          }
        }
        GRAPHQL
      end

      it 'returns those image urls' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1

        node_response = submissions_response['edges'][0]['node']
        asset_response = node_response['assets'][0]
        expect(asset_response['imageUrls']).to eq image_urls
      end
    end

    context 'with an asset that has not been processed' do
      let!(:asset) { Fabricate :unprocessed_image, submission: submission }

      let(:query) do
        <<-GRAPHQL
        query {
          submissions(#{query_inputs}) {
            edges {
              node {
                assets {
                  imageUrls
                }
              }
            }
          }
        }
        GRAPHQL
      end

      it 'returns an empty object' do
        post '/api/graphql', params: { query: query }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submissions_response = body['data']['submissions']
        expect(submissions_response['edges'].count).to eq 1

        node_response = submissions_response['edges'][0]['node']
        asset_response = node_response['assets'][0]
        expect(asset_response['imageUrls']).to eq({})
      end
    end
  end
end
