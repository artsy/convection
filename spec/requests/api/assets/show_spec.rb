# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "Show Asset" do
  let(:jwt_token) do
    JWT.encode({aud: "gravity", sub: "userid"}, Convection.config.jwt_secret)
  end
  let(:headers) { {"Authorization" => "Bearer #{jwt_token}"} }

  describe "GET /assets/:id" do
    it "rejects unauthorized requests" do
      get "/api/assets/foo",
          headers: {
            "Authorization" => "Bearer foo.bar.baz"
          }
      expect(response.status).to eq 401
    end

    it "returns an error if it cannot find the asset" do
      Fabricate(:image)
      get "/api/assets/foo", headers: headers
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)["error"]).to eq "Not Found"
    end

    it "rejects requests for someone else's submission" do
      submission =
        Fabricate(
          :submission,
          artist_id: "andy-warhol",
          user: Fabricate(:user, gravity_user_id: "buster-bluth")
        )
      asset = Fabricate(:image, submission: submission)
      get "/api/assets/#{asset.id}", headers: headers
      expect(response.status).to eq 401
    end

    it "accepts requests for your own submission" do
      submission =
        Fabricate(
          :submission,
          artist_id: "andy-warhol",
          user: Fabricate(:user, gravity_user_id: "userid")
        )
      asset = Fabricate(:image, submission: submission)
      get "/api/assets/#{asset.id}", headers: headers
      expect(response.status).to eq 200
      body = JSON.parse(response.body)
      expect(body["submission_id"]).to eq submission.id
      expect(body["id"]).to eq asset.id
    end
  end
end
