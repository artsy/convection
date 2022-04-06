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
    '{ state: REJECTED, clientMutationId: "2", artistID: "andy", title: "soup", category: JEWELRY, minimumPriceDollars: 50000, currency: "GBP", sourceArtworkID: "gravity_artwork_id", myCollectionArtworkID: "my_collection_artwork_id" }'
  end

  let(:mutation) { <<-GRAPHQL }
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

  before { add_default_stubs(email: 'michael@bluth.com', artist_id: 'andy') }

  describe 'requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'create user with gravity_auser_id eq nil if contact information is not provided' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(User.last).to eq nil
      end

      context 'contact information is provided' do
        let(:mutation) { <<-GRAPHQL }
          mutation {
            createConsignmentSubmission(input: {artistID: "andy", userName: "foo", userEmail: "bar", userPhone: "baz"}){
              clientMutationId
              consignmentSubmission {
                userName
                userEmail
                userPhone
              }
            }
          }
        GRAPHQL

        it 'creates a submission' do
          post '/api/graphql', params: { query: mutation }, headers: headers

          body = JSON.parse(response.body)
          submission =
            body['data']['createConsignmentSubmission']['consignmentSubmission']
          expect(submission).to eq(
            { 'userName' => 'foo', 'userEmail' => 'bar', 'userPhone' => 'baz' }
          )
        end
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
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        submission = Submission.first
        expect(submission.user_agent).to eq 'something, something'
      end
    end

    context 'with provided source' do
      let(:mutation_inputs) { '{ artistID: "andy", source: WEB_INBOUND }' }

      it 'creates a submission with correct source' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        submission = Submission.first

        expect(submission.source).to eq 'web_inbound'
      end
    end

    context 'with postal code' do
      let(:mutation_inputs) do
        '{ artistID: "andy", locationPostalCode: "12345", locationCountryCode: "us" }'
      end

      it 'creates a submission with correct address' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        submission = Submission.first

        expect(submission.location_postal_code).to eq '12345'
        expect(submission.location_country_code).to eq 'us'
      end
    end
  end
end
