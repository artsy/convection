class ConsignmentInquiryService
  def self.post_consignment_created_event(consignment_inquiry)
    Artsy::EventPublisher.publish(
      "consignments",
      "consignmentinquiry.created",
      verb: "created",
      subject: {id: consignment_inquiry.gravity_user_id},
      object: {id: consignment_inquiry.id.to_s, root_type: consignment_inquiry.class.name},
      properties: {
        email: consignment_inquiry.email, # email of user sending inquiry
        recipient_email: consignment_inquiry.recipient_email, # optional email of team member (or Pulse will deliver to sell@artsy.net if absent)
        message: consignment_inquiry.message,
        name: consignment_inquiry.name,
        phone_number: consignment_inquiry.phone_number
      }
    )
  end
end
