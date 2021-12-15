# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'removeAssetFromConsignmentSubmission mutation' do
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
    }, filename: \"testname\", geminiToken: \"gemini-token-hash\" }"
  end

  let(:createMutation) { <<-GRAPHQL }
      mutation {
        addAssetToConsignmentSubmission(input: #{mutation_inputs}){
          clientMutationId
          asset {
            id
            submissionId
          }
        }
      }
  GRAPHQL

  let(:removeMutation) { <<-GRAPHQL }
      mutation {
        removeAssetFromConsignmentSubmission(input: #{mutation_inputs}){}
      }
  GRAPHQL



  describe 'valid requests' do
    it 'creates an asset' do
      expect {
        post '/api/graphql', params: { query: createMutation }, headers: headers
      }.to change(Asset, :count).by(1)

      expect {
        post '/api/graphql', params: { query: removeMutation }, headers: headers
      }.to change(Asset, :count).by(1)
    end
  end

end
