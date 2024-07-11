# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

shared_examples "successfull creation" do
  it "creates an asset" do
    expect {
      post "/api/graphql", params: {query: mutation}, headers: headers
    }.to change(Asset, :count).by(1)

    expect(response.status).to eq 200

    body = JSON.parse(response.body)

    asset_response = body["data"]["addAssetToConsignmentSubmission"]["asset"]
    asset = Asset.find(asset_response["id"])

    expect(asset.filename).to eq "testname"
    expect(asset.submission).to eq(submission)
  end
end

describe "addAssetToConsignmentSubmission mutation" do
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
        addAssetToConsignmentSubmission(input: #{mutation_inputs}){
          clientMutationId
          asset {
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
          }, filename: \"testname\", geminiToken: \"gemini-token-hash\" }"
        end
      end
    end

    context "working with external_id" do
      it_behaves_like "successfull creation" do
        let(:mutation_inputs) do
          "{ clientMutationId: \"test\", externalSubmissionId: \"#{
            submission.uuid
          }\", filename: \"testname\", geminiToken: \"gemini-token-hash\" }"
        end
      end
    end

    context "allows s3 path and bucket inputs" do
      let!(:mutation_inputs) do
        "{ clientMutationId: \"test\", externalSubmissionId: \"#{
          submission.uuid
        }\", filename: \"1.pdf\", source: { key: \"PATH1\", bucket: \"BUCKET1\" } }"
      end

      let!(:mutation) { <<-GRAPHQL }
        mutation {
          addAssetToConsignmentSubmission(input: #{mutation_inputs}){
            clientMutationId
            asset {
              id
              submissionId
              s3Path
              s3Bucket
            }
          }
        }
      GRAPHQL

      it "creates asset" do
        s3_double = double(object: double(size: "150"))
        allow(S3).to receive(:new).and_return(s3_double)

        expect {
          post "/api/graphql", params: {query: mutation}, headers: headers
        }.to change(Asset, :count).by(1)

        body = JSON.parse(response.body)

        asset_response = body["data"]["addAssetToConsignmentSubmission"]["asset"]
        asset = Asset.find(asset_response["id"])

        expect(asset.filename).to eq "1.pdf"
        expect(asset.submission).to eq(submission)
        expect(asset_response["s3Path"]).to eq("PATH1")
        expect(asset_response["s3Bucket"]).to eq("BUCKET1")
      end
    end
  end

  describe "requests with a wrong userID and sessionId" do
    let(:token) do
      payload = {aud: "gravity", sub: "", roles: "user"}
      JWT.encode(payload, Convection.config.jwt_secret)
    end

    let(:mutation_inputs) do
      "{
        clientMutationId: \"test\",
        submissionID: #{submission.id},
        sessionID: \"test-id\"
        geminiToken: \"gemini-token-hash\"
      }"
    end

    it "does not alter the assets count and resolves with an error message" do
      expect {
        post "/api/graphql", params: {query: mutation}, headers: headers
      }.to change(Asset, :count).by(0)

      expect(response.status).to eq 200

      body = JSON.parse(response.body)

      error_message = body["errors"][0]["message"]
      expect(error_message).to eq "Submission Not Found"
    end
  end
end
