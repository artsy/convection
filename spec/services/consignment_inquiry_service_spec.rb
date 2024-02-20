# frozen_string_literal: true

require "rails_helper"

describe ConsignmentInquiryService do
  let(:consignment_inquiry) { Fabricate(:consignment_inquiry) }
    
  describe "#post_consignment_created_event" do
    it "calls Artsy::EventService.post_event with an instance of BaseEvent" do
      expect(Artsy::EventService).to receive(:post_event)
        .once
        .with(topic: "consignments", event: instance_of(ConsignmentInquiryEvent))
        ConsignmentInquiryService.post_consignment_created_event(consignment_inquiry)
    end
  end
end
