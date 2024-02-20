class ConsignmentInquiry < ApplicationRecord
  # the email of user sending the inquiry
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}
   # recipient_email is an optional email of a collector services team member to deliver the inquiry to. On Pulse if this is absent, the inquiry will be delivered to sell@artsy.net
  validates :recipient_email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_nil: true
  validates :name, presence: {message: "is required"}
  validates :message, presence: {message: "is required"}
end
