# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'addAssetToConsignmentSubmission mutation' do
  let(:user) { Fabricate(:user, gravity_user_id: 'userid') }
  let(:submission) { Fabricate(:submission, user: user) }

  let(:token) do
    payload = { aud: 'gravity', sub: user.gravity_user_id, roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:mutation_inputs) do
    "{ clientMutationId: \"test\", submissionID: #{
      submission.id
    }, geminiToken: \"gemini-token-hash\" }"
  end

  let(:mutation) do
    <<-GRAPHQL
      mutation {
        addAssetToConsignmentSubmission(input: #{mutation_inputs}){
          clientMutationId
          asset {
            id
            submission_id
          }
        }
      }
    GRAPHQL
  end

  describe 'valid requests' do
    it 'creates an asset' do
      expect {
        post '/api/graphql', params: { query: mutation }, headers: headers
      }.to change(Asset, :count).by(1)

      expect(response.status).to eq 200

      body = JSON.parse(response.body)

      asset_response = body['data']['addAssetToConsignmentSubmission']['asset']
      expect(asset_response['id']).not_to be_nil
      expect(asset_response['submission_id'].to_i).to eq submission.id
    end
  end
end
