# frozen_string_literal: true

require "rails_helper"

describe Api::ConsignmentInquiriesController, type: :controller do
  before do
    allow_any_instance_of(Api::ConsignmentInquiriesController).to receive(
      :ensure_trusted_app_or_user
    )
  end

  describe "#create" do
    it "creates a ConsignmentInquiry" do
      allow(Artsy::EventPublisher).to receive(:publish)
      expect {
        post :create,
          params: {
            email: "user@email.com",
            name: "User Test",
            message: "This is the message"
          }
      }.to change(ConsignmentInquiry, :count).by(1)
    end

    it "posts events when created" do
      expect(Artsy::EventPublisher).to receive(:publish).with(
        "consignments",
        "consignmentinquiry.created",
        anything
      )
      post :create,
        params: {
          email: "user@email.com",
          name: "User Test",
          message: "This is the message"
        }
    end
  end
end
