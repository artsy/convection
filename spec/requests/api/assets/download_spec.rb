# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "Download Asset" do
  let!(:user) { Fabricate(:user, gravity_user_id: "userid") }
  let!(:submission) do
    Fabricate(
      :submission,
      artist_id: "andy-warhol",
      user: user
    )
  end
  let!(:asset) { Fabricate(:additional_file, submission: submission) }

  let(:jwt_token) do
    JWT.encode({aud: "gravity", sub: user.gravity_user_id}, Convection.config.jwt_secret)
  end
  let(:headers) { {"Authorization" => "Bearer #{jwt_token}"} }

  describe "GET /download" do
    context "un-authenticated request" do
      it "rejects request" do
        get "/api/assets/#{asset.id}/download",
          headers: {
            "Authorization" => "Bearer foo.bar.baz"
          }
        expect(response.status).to eq 401
      end
    end

    context "un-authorized user" do
      let(:another_user) { Fabricate(:user, gravity_user_id: "anotherid") }
      let(:jwt_token) do
        JWT.encode({aud: "gravity", sub: another_user.gravity_user_id}, Convection.config.jwt_secret)
      end
      let(:headers) { {"Authorization" => "Bearer #{jwt_token}"} }

      it "rejects request" do
        get "/api/assets/#{asset.id}/download", headers: headers

        expect(response.status).to eq 401
      end
    end

    context "authorized user" do
      it "allows to download asset" do
        expect(AssetDownloader).to receive(:new).and_return(double(data: "filedata"))

        get "/api/assets/#{asset.id}/download", headers: headers

        expect(response.status).to eq 200
        expect(response.body).to eq "filedata"
      end
    end
  end
end
