# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

shared_examples "successfull creation" do
  it "creates an asset" do
    expect {
      post "/api/graphql", params: {query: mutation}, headers: headers
    }.to change(Asset, :count).by(2)

    expect(response.status).to eq 200

    body = JSON.parse(response.body)

    asset_response = body["data"]["addAssetsToConsignmentSubmission"]["assets"]
    expect(Asset.find(asset_response[0]["id"]).submission).to eq(submission)
    expect(Asset.find(asset_response[1]["id"]).submission).to eq(submission)
  end
end

describe "addAssetsToConsignmentSubmission mutation" do
  let(:user) { Fabricate(:user, gravity_user_id: "userid") }
  let(:submission) { Fabricate(:submission, user: user) }

  let(:token) do
    payload = {aud: "gravity", sub: user.gravity_user_id, roles: "user"}
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { {"Authorization" => "Bearer #{token}"} }

  let(:mutation_inputs) { "" }
  let(:mutation) { <<-GRAPHQL }
      mutation {
        addAssetsToConsignmentSubmission(input: #{mutation_inputs}){
          clientMutationId
          assets {
            id
            submissionId
          }
        }
      }
  GRAPHQL

  context "valid requests" do
    context "working with sequential id" do
      it_behaves_like "successfull creation" do
        let(:mutation_inputs) do
          "{ clientMutationId: \"test\", submissionID: #{
            submission.id
          }, geminiTokens: [\"gemini-token-hash\", \"gemini-token-hash2\"] }"
        end
      end
    end

    context "working with external_id" do
      it_behaves_like "successfull creation" do
        let(:mutation_inputs) do
          "{ clientMutationId: \"test\", externalSubmissionId: \"#{
            submission.uuid
          }\", geminiTokens: [\"gemini-token-hash\", \"gemini-token-hash2\"] }"
        end
      end
    end
  end
end
