# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe "Submission Flow" do
  let(:jwt_token) do
    JWT.encode({aud: "gravity", sub: "userid"}, Convection.config.jwt_secret)
  end
  let(:headers) { {"Authorization" => "Bearer #{jwt_token}"} }

  before do
    allow(Convection.config).to receive(:access_token).and_return("auth-token")
    add_default_stubs(email: "michael@bluth.com")
    expect(NotificationService).to receive(:post_submission_event).once
  end

  it "Completes a submission from Tokyo" do
    # first create the submission, without a location_city
    post "/api/submissions",
      params: {
        artist_id: "artistid",
        user:
          Fabricate(
            :user,
            gravity_user_id: "userid",
            email: "michael@bluth.com"
          ),
        title: "My Artwork",
        medium: "painting",
        year: "1992",
        height: "12",
        width: "14",
        dimensions_metric: "in",
        location_state: "Tokyo",
        location_country: "Japan",
        category: "Painting"
      },
      headers: headers

    expect(response.status).to eq 201
    submission = Submission.find(JSON.parse(response.body)["id"])
    expect(submission.assets.count).to eq 0

    put "/api/submissions/#{submission.id}",
      params: {
        state: "submitted"
      },
      headers: headers
    expect(response.status).to eq 201
    expect(submission.reload.state).to eq "submitted"

    emails = ActionMailer::Base.deliveries
    expect(emails.length).to eq 1
    expect(emails.first.html_part.body).to include(
      "Unfortunately, we’re not accepting consignments right now."
    )
  end

  describe "Creating a submission without a photo initially" do
    it "sends an initial reminder and a delayed reminder" do
      # first create the submission
      post "/api/submissions",
        params: {
          artist_id: "artistid",
          user:
            Fabricate(
              :user,
              gravity_user_id: "userid",
              email: "michael@bluth.com"
            ),
          title: "My Artwork",
          medium: "painting",
          year: "1992",
          height: "12",
          width: "14",
          dimensions_metric: "in",
          location_city: "New York",
          category: "Painting"
        },
        headers: headers

      expect(response.status).to eq 201
      @submission = Submission.find(JSON.parse(response.body)["id"])

      expect(@submission.assets.count).to eq 0

      put "/api/submissions/#{@submission.id}",
        params: {
          state: "submitted"
        },
        headers: headers
      expect(response.status).to eq 201
      expect(@submission.reload.state).to eq "submitted"
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include(
        "Unfortunately, we’re not accepting consignments right now."
      )
    end
  end

  describe "Creating a submission (as a client might) with a photo" do
    it "creates and updates a submission/assets" do
      # first create the submission
      post "/api/submissions",
        params: {
          artist_id: "artistid",
          user: Fabricate(:user, gravity_user_id: "userid"),
          title: "My Artwork",
          medium: "painting",
          year: "1992",
          height: "12",
          width: "14",
          dimensions_metric: "in",
          location_city: "New York",
          category: "Painting"
        },
        headers: headers

      expect(response.status).to eq 201
      submission = Submission.find(JSON.parse(response.body)["id"])

      # upload assets to that submission
      post "/api/assets",
        params: {
          submission_id: submission.id,
          gemini_token: "gemini-token"
        },
        headers: headers

      post "/api/assets",
        params: {
          submission_id: submission.id,
          gemini_token: "gemini-token2"
        },
        headers: headers

      expect(submission.assets.count).to eq 2
      expect(submission.assets.map(&:image_urls).uniq).to eq([{}])

      # accept gemini callbacks for image urls
      post "/api/callbacks/gemini",
        params: {
          access_token: "auth-token",
          token: "gemini-token",
          image_url: {
            square: "https://new-image.jpg"
          },
          metadata: {
            id: submission.id
          }
        }

      post "/api/callbacks/gemini",
        params: {
          access_token: "auth-token",
          token: "gemini-token2",
          image_url: {
            square: "https://another-image.jpg"
          },
          metadata: {
            id: submission.id
          }
        }
      expect(
        submission.assets.detect { |a| a.gemini_token == "gemini-token" }.reload
          .image_urls
      ).to eq("square" => "https://new-image.jpg")
      expect(
        submission.assets.detect { |a|
          a.gemini_token == "gemini-token2"
        }.reload.image_urls
      ).to eq("square" => "https://another-image.jpg")

      # update the submission status and notify
      put "/api/submissions/#{submission.id}",
        params: {
          state: "submitted"
        },
        headers: headers
      expect(response.status).to eq 201
      expect(submission.reload.state).to eq "submitted"
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      # expect(emails[0].html_part.body).to include("https://new-image.jpg")

      # GET to retrieve the image url for the submission
      get "/api/assets",
        params: {
          submission_id: submission.id
        },
        headers: headers
      expect(response.status).to eq 200
      expect(
        JSON.parse(response.body).map { |a| a["gemini_token"] }
      ).to include("gemini-token", "gemini-token2")
    end
  end
end
