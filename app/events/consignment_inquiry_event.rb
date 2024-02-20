# frozen_string_literal: true

class ConsignmentInquiryEvent < Events::BaseEvent
  TOPIC = "consignments"
  ACTION = "created"

  def subject
    {
      id: @object.id.to_s
    }
  end

  def properties
    {
      email: @object.email, # the email of user sending the inquiry
      recipient_email: @object.recipient_email, # an optional email of a collector services team member to deliver the inquiry. On Pulse if this is absent, the inquiry will be delivered to sell@artsy.net
      gravity_user_id: @object.gravity_user_id,
      message: @object.message,
      name: @object.name,
      phone_number: @object.phone_number

    }
  end
end
