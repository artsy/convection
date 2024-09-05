# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "addUserToSubmission mutation" do
  let(:user) { Fabricate(:user, gravity_user_id: "userid") }

  let(:token) do
    payload = {aud: "gravity", sub: user.gravity_user_id, roles: "user"}
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { {"Authorization" => "Bearer #{token}"} }

  before do
    allow(Convection.config).to receive(:send_new_receipt_email).and_return(true)
  end

  it "associates a user with an unclaimed draft submission, referenced by UUID" do
    submission = Fabricate(:submission, user: nil, my_collection_artwork_id: nil)

    mutation = <<-GRAPHQL
        mutation {
          addUserToSubmission(input: { id: \"#{submission.uuid}\" }) {
            clientMutationId
            consignmentSubmission {
              externalId
            }
          }
        }
    GRAPHQL

    expect(SubmissionService).to receive(:create_my_collection_artwork).and_return(true)

    post "/api/graphql", params: {query: mutation}, headers: headers

    expect(response.status).to eq 200
    body = JSON.parse(response.body)

    expect(body["data"]["addUserToSubmission"]["consignmentSubmission"]["externalId"]).to eq submission.uuid
  end

  it "no-ops and returns the submission if the current user is already associated with the submission" do
    submission = Fabricate(:submission, user: user)

    mutation = <<-GRAPHQL
        mutation {
          addUserToSubmission(input: { id: \"#{submission.uuid}\" }) {
            clientMutationId
            consignmentSubmission {
              externalId
            }
          }
        }
    GRAPHQL

    post "/api/graphql", params: {query: mutation}, headers: headers

    expect(response.status).to eq 200
    body = JSON.parse(response.body)

    expect(body["data"]["addUserToSubmission"]["consignmentSubmission"]["externalId"]).to eq submission.uuid
  end

  it "returns an error if the submission has already been claimed by a different user" do
    submission = Fabricate(:submission, user: Fabricate(:user))

    mutation = <<-GRAPHQL
        mutation {
          addUserToSubmission(input: { id: \"#{submission.uuid}\" }) {
            clientMutationId
            consignmentSubmission {
              externalId
            }
          }
        }
    GRAPHQL

    expect {
      post "/api/graphql", params: {query: mutation}, headers: headers
    }.to change(Asset, :count).by(0)

    expect(response.status).to eq 200

    body = JSON.parse(response.body)

    error_message = body["errors"][0]["message"]
    expect(error_message).to eq "Submission already has a user"
  end

  it "returns an error if the submission is not in a draft state" do
    submission = Fabricate(:submission, user: nil, state: Submission::SUBMITTED)

    mutation = <<-GRAPHQL
        mutation {
          addUserToSubmission(input: { id: \"#{submission.uuid}\" }) {
            clientMutationId
            consignmentSubmission {
              externalId
            }
          }
        }
    GRAPHQL

    expect {
      post "/api/graphql", params: {query: mutation}, headers: headers
    }.to change(Asset, :count).by(0)

    expect(response.status).to eq 200

    body = JSON.parse(response.body)

    error_message = body["errors"][0]["message"]
    expect(error_message).to eq "Submission must be in a draft state to claim"
  end

  it "returns an error if trying to query and claim a submission by sequential internal ID" do
    submission = Fabricate(:submission, user: nil)

    mutation = <<-GRAPHQL
        mutation {
          addUserToSubmission(input: { id: \"#{submission.id}\" }) {
            clientMutationId
            consignmentSubmission {
              externalId
            }
          }
        }
    GRAPHQL

    post "/api/graphql", params: {query: mutation}, headers: headers

    expect(response.status).to eq 200
    body = JSON.parse(response.body)

    error_message = body["errors"][0]["message"]
    expect(error_message).to eq "Submission Not Found"
  end
end
