# frozen_string_literal: true

require "rails_helper"

describe NotificationService do
  let(:submission) do
    Fabricate(
      :submission,
      artist_id: "artistid",
      user: Fabricate(:user, gravity_user_id: "userid"),
      title: "My Artwork",
      medium: "painting",
      year: "1992",
      height: "12",
      width: "14",
      dimensions_metric: "in",
      location_city: "New York",
      category: "Painting",
      state: "submitted"
    )
  end

  describe "#post_submission_event" do
    it "publishes submission event" do
      expect(Artsy::EventPublisher).to receive(:publish).once.with(
        "consignments",
        "submission.submitted",
        verb: "submitted",
        subject: {id: "userid", display: "userid (New York)"},
        object: {id: submission.id.to_s, display: "#{submission.id} (submitted)"},
        properties: hash_including(
          medium: "painting",
          category: "Painting",
          year: "1992"
        )
      )
      NotificationService.post_submission_event(submission.id, "submitted")
    end
  end
end
