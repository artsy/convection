# frozen_string_literal: true

require "rails_helper"

describe ConsignmentInquiryService do
  let(:consignment_inquiry) do
    Fabricate(
      :consignment_inquiry,
      gravity_user_id: "guid",
      name: "foo",
      email: "test@example.com",
      message: "bar"
    )
  end

  describe "#post_consignment_created_event" do
    it "publishes consignment inquiry event" do
      expect(Artsy::EventPublisher).to receive(:publish).once.with(
        "consignments",
        "consignmentinquiry.created",
        verb: "created",
        subject: {id: "guid"},
        object: {id: consignment_inquiry.id.to_s, root_type: "ConsignmentInquiry"},
        properties: hash_including(
          email: "test@example.com",
          name: "foo",
          message: "bar"
        )
      )
      ConsignmentInquiryService.post_consignment_created_event(consignment_inquiry)
    end
  end
end
