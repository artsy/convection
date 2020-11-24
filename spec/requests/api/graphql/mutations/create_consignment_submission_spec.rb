# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'createConsignmentSubmission mutation' do
  let(:token) do
    payload = { aud: 'gravity', sub: 'userid', roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:mutation_inputs) do
    '{ state: REJECTED, clientMutationId: "2", artistID: "andy", title: "soup", category: JEWELRY, minimumPriceDollars: 50000, currency: "GBP", sourceArtworkID: "gravity_artwork_id" }'
  end

  let(:mutation) do
    <<-GRAPHQL
    mutation {
      createConsignmentSubmission(input: #{mutation_inputs}){
        clientMutationId
        consignmentSubmission {
          id
          title
          category
          state
          minimumPriceDollars
          currency
          sourceArtworkID
        }
      }
    }
    GRAPHQL
  end

  describe 'invalid requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body['data']['createConsignmentSubmission']
        expect(create_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access createConsignmentSubmission"
      end
    end

    context 'with a request missing an app token' do
      let(:token) do
        payload = { sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        create_response = body['data']['createConsignmentSubmission']
        expect(create_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq "Can't access createConsignmentSubmission"
      end
    end

    context 'with a request missing an artist_id' do
      let(:mutation_inputs) { '{ title: "soup" }' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to match 'is required'
      end
    end
  end

  describe 'valid requests' do
    it 'creates a submission' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect {
        post '/api/graphql', params: { query: mutation }, headers: headers
      }.to change(Submission, :count).by(1)

      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      create_response = body['data']['createConsignmentSubmission']

      submission_response = create_response['consignmentSubmission']
      expect(submission_response).to include(
        {
          # this ensures it's not nil
          'id' => be,
          'title' => 'soup',
          'category' => 'Jewelry',
          'state' => 'REJECTED',
          'minimumPriceDollars' => 50_000,
          'currency' => 'GBP',
          'sourceArtworkID' => 'gravity_artwork_id'
        }
      )

      mutation_id = create_response['clientMutationId']
      expect(mutation_id).to eq '2'

      created_submission = Submission.find(submission_response['id'])
      expect(submission_response['title']).to eq(created_submission.title)
      expect(submission_response['category']).to eq(created_submission.category)
      expect(created_submission.rejected?).to be true
      expect(submission_response['minimumPriceDollars']).to eq(
        created_submission.minimum_price_dollars
      )
      expect(submission_response['currency']).to eq(created_submission.currency)
      expect(submission_response['sourceArtworkID']).to eq(
        created_submission.source_artwork_id
      )
    end

    context 'with a user agent string' do
      let(:mutation_inputs) do
        '{ artistID: "andy", userAgent: "something, something" }'
      end

      it 'sets that UA on the submission' do
        stub_gravity_root
        stub_gravity_user
        stub_gravity_user_detail(email: 'michael@bluth.com')

        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        submission = Submission.first
        expect(submission.user_agent).to eq 'something, something'
      end
    end
  end
end
