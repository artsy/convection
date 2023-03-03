# frozen_string_literal: true

class ConsignmentInquiryEvent < Events::BaseEvent
  TOPIC = 'consignments'
  ACTION = 'created'

  def subject
    {
      id: @object.id.to_s
    }
  end

  def properties
    {
      email: @object.email,
      recipient_email: @object.recipient_email,
      gravity_user_id: @object.gravity_user_id,
      message: @object.message,
      name: @object.name,
      phone_number: @object.phone_number
        
    }
  end 
end
