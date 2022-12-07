# frozen_string_literal: true

Fabricator(:consignment_inquiry) do
  email "test@email.com"
  gravity_user_id "gravity-user-id"
  message "The message"
  name "Test User"
  phone_number "+49283938382"
end
