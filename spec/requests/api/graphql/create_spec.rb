# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'Create Submission With Graphql' do
  let(:jwt_token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'user' },
      Convection.config.jwt_secret
    )
  end
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  let(:create_mutation) do
    <<-GRAPHQL
    mutation {
      createConsignmentSubmission(input: { state: REJECTED, clientMutationId: "2", artist_id: "andy", title: "soup", category: JEWELRY, minimum_price_dollars: 50000, currency: "GBP" }){
        clientMutationId
        consignment_submission {
          id
          title
          category
          state
          minimum_price_dollars
          currency
        }
      }
    }
    GRAPHQL
  end

  let(:create_mutation_no_artist_id) do
    <<-GRAPHQL
    mutation {
      createConsignmentSubmission(input: { title: "soup" }){
        consignment_submission {
          id
          title
        }
      }
    }
    GRAPHQL
  end

  describe 'POST /graphql' do
    it 'rejects unauthorized requests' do
      post '/api/graphql',
           params: { query: create_mutation },
           headers: { 'Authorization' => 'Bearer foo.bar.baz' }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['createConsignmentSubmission']).to eq nil
      expect(
        body['errors'][0]['message']
      ).to eq "Can't access createConsignmentSubmission"
    end

    it 'rejects requests without an app token' do
      user_token =
        JWT.encode(
          { sub: 'userid', roles: 'user' },
          Convection.config.jwt_secret
        )
      post '/api/graphql',
           params: { query: create_mutation },
           headers: { 'Authorization' => "Bearer #{user_token}" }
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body['data']['createConsignmentSubmission']).to eq nil
      expect(
        body['errors'][0]['message']
      ).to eq "Can't access createConsignmentSubmission"
    end

    it 'rejects when missing artist_id' do
      post '/api/graphql',
           params: { query: create_mutation_no_artist_id }, headers: headers
      expect(response.status).to eq 200
    end

    it 'creates a submission' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')

      expect {
        post '/api/graphql',
             params: { query: create_mutation }, headers: headers
        expect(response.status).to eq 200
        body = JSON.parse(response.body)
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'id'
          ]
        ).not_to be_nil
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'title'
          ]
        ).to eq 'soup'
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'category'
          ]
        ).to eq 'JEWELRY'
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'state'
          ]
        ).to eq 'REJECTED'
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'minimum_price_dollars'
          ]
        ).to eq 50_000
        expect(
          body['data']['createConsignmentSubmission']['consignment_submission'][
            'currency'
          ]
        ).to eq 'GBP'
        expect(
          body['data']['createConsignmentSubmission']['clientMutationId']
        ).to eq '2'
      }.to change(Submission, :count).by(1)
    end

    it 'creates an asset' do
      expect {
        submission =
          Fabricate(
            :submission,
            user: Fabricate(:user, gravity_user_id: 'userid')
          )

        create_asset = <<-GRAPHQL
        mutation {
          addAssetToConsignmentSubmission(input: { clientMutationId: "test", submission_id: #{
          submission.id
        }, gemini_token: "gemini-token-hash" }){
            clientMutationId
            asset {
              id
              submission_id
            }
          }
        }
        GRAPHQL

        post '/api/graphql', params: { query: create_asset }, headers: headers
        expect(response.status).to eq 200

        body = JSON.parse(response.body)
        expect(
          body['data']['addAssetToConsignmentSubmission']['asset']['id']
        ).not_to be_nil
        expect(
          body['data']['addAssetToConsignmentSubmission']['asset'][
            'submission_id'
          ]
            .to_i
        ).to eq submission.id
      }.to change(Asset, :count).by(1)
    end
  end
end
