class ConsignmentInquiry < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :recipient_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :name, presence: { message: "is required" }
  validates :message, presence: { message: "is required" }
end
