class ConsignmentInquiryService
  def self.post_consignment_created_event(consignment_inquiry)
    event = ConsignmentInquiryEvent.new(
      model: consignment_inquiry, 
      action: ConsignmentInquiryEvent::ACTION
    )
    Artsy::EventService.post_event(
      topic: ConsignmentInquiryEvent::TOPIC,
      event: event
    )
  end
end
