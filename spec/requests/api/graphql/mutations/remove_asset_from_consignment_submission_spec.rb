# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "removeAssetFromConsignmentSubmission mutation" do
  let(:user) { Fabricate(:user, gravity_user_id: "userid") }
  let(:submission) { Fabricate(:submission, user: user) }
  let(:asset) do
    Fabricate(:asset, id: 1, submission: submission, asset_type: "image")
  end

  let(:token) do
    payload = {aud: "gravity", sub: user.gravity_user_id, roles: "user"}
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { {"Authorization" => "Bearer #{token}"} }

  let(:create_mutation_inputs) do
    "{ clientMutationId: \"test\", submissionID: #{
      submission.id
    }, filename: \"testname\", geminiToken: \"gemini-token-hash\", sessionID: \"1\" }"
  end

  let(:remove_mutation_inputs) do
    "{ clientMutationId: \"test\", assetID: \"1\", sessionID: \"1\"}"
  end

  let(:createMutation) { <<-GRAPHQL }
      mutation {
        addAssetToConsignmentSubmission(input: #{create_mutation_inputs}){
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
        removeAssetFromConsignmentSubmission(input: #{remove_mutation_inputs}){
          clientMutationId
          asset {
            id
            submissionId
          }
        }
      }
  GRAPHQL

  describe "valid requests" do
    it "removes an asset from submission successfully" do
      expect {
        post "/api/graphql", params: {query: createMutation}, headers: headers
      }.to change(Asset, :count).by(1)

      expect(Asset.count).to eq 1

      expect {
        post "/api/graphql", params: {query: removeMutation}, headers: headers
      }.to change(Asset, :count).by(-1)

      expect(Asset.count).to eq 0
    end
  end
end
