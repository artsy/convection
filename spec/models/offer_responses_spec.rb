# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe OfferResponse do
  context 'intended_state' do
    it 'allows only certain intended_states' do
      expect(OfferResponse.new(intended_state: 'blah')).not_to be_valid
      expect(OfferResponse.new(intended_state: Offer::ACCEPTED)).to be_valid
      expect(OfferResponse.new(intended_state: Offer::SENT)).not_to be_valid
    end

    it 'is required' do
      expect(OfferResponse.new).not_to be_valid
    end
  end

  context 'rejection_reason' do
    it 'allows only certain rejection_reasons' do
      expect(
        OfferResponse.new(
          intended_state: Offer::REJECTED, rejection_reason: 'Low estimate'
        )
      ).to be_valid
      expect(
        OfferResponse.new(
          intended_state: Offer::REJECTED, rejection_reason: 'meow'
        )
      ).not_to be_valid
    end
  end
end
