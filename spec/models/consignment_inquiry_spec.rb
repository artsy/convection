# frozen_string_literal: true

require 'rails_helper'

describe ConsignmentInquiry do
  context 'Validations' do
    it 'validates email format' do
      expect do
        ConsignmentInquiry.create!(
          email: "emailisnotvalid",
          message: "Is a valid message",
          name: "Valid Name"
        )
      end.to raise_error "Validation failed: Email is invalid"
    end
    it 'requires name' do
      expect do
        ConsignmentInquiry.create!(
          email: "email@email.com",
          message: "Is a valid message"
        )
      end.to raise_error "Validation failed: Name is required"
      
    end
    it 'requires message' do
      expect do
        ConsignmentInquiry.create!(
          email: "email@email.com",
          name: "Valid Name"
        )
      end.to raise_error "Validation failed: Message is required"
      
    end
  end
end
