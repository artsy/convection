class ConsignmentInquiry < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: { message: "is required" }
  validates :message, presence: { message: "is required" }
end
