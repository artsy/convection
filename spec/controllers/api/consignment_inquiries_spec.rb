# frozen_string_literal: true

require 'rails_helper'

describe Api::ConsignmentInquiriesController, type: :controller do
  before do
    allow_any_instance_of(Api::ConsignmentInquiriesController).to receive(
      :require_trusted_app_without_current_user
    )
  end

  describe '#create' do
    it "creates a ConsignmentInquiry" do
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
      expect(Artsy::EventService).to receive(:post_event).with(
                                                          hash_including(
                                                            topic: ConsignmentInquiryEvent::TOPIC
                                                          ))
      post :create, 
        params: { 
          email: "user@email.com",
          name: "User Test",
          message: "This is the message"
        }
    end
  end
end
