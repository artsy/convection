require 'rails_helper'
require 'support/gravity_helper'

describe Offer do
  let(:offer) { Fabricate(:offer) }

  context 'state' do
    it 'correctly sets the initial state to sent' do
      offer2 = Fabricate(:offer, state: nil)
      expect(offer2.state).to eq 'draft'
    end

    it 'allows only certain states' do
      expect(Offer.new(state: 'blah')).not_to be_valid
      expect(Offer.new(state: 'sent')).to be_valid
    end
  end

  context 'type' do
    it 'allows only certain types' do
      expect(Offer.new(offer_type: 'blah')).not_to be_valid
      expect(Offer.new(offer_type: 'auction consignment')).to be_valid
      expect(Offer.new(offer_type: 'purchase')).to be_valid
      expect(Offer.new(offer_type: 'consignment period')).to be_valid
    end
  end

  context 'currency' do
    it 'allows only certain currencies' do
      expect(Offer.new(currency: 'blah')).not_to be_valid
      expect(Offer.new(currency: 'USD')).to be_valid
      expect(Offer.new(currency: 'EUR')).to be_valid
      expect(Offer.new(currency: 'GBP')).to be_valid
    end
  end

  context 'reference_id' do
    it 'generates a reference id when creating the object' do
      expect(offer.reference_id).to_not be_nil
    end
  end

  context 'submission' do
    it 'sets the submission' do
      expect(offer.submission).to eq offer.partner_submission.submission
    end
  end

  context 'rejection_reason' do
    it 'allows only certain rejection reasons' do
      expect(Offer.new(rejection_reason: 'blah')).not_to be_valid
      expect(Offer.new(rejection_reason: 'Other')).to be_valid
      expect(Offer.new(rejection_reason: 'Low estimate')).to be_valid
    end
  end
end
