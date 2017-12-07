require 'rails_helper'
require 'support/gravity_helper'

describe Offer do
  let(:offer) { Fabricate(:offer) }

  context 'state' do
    it 'correctly sets the initial state to sent' do
      offer2 = Fabricate(:offer, state: nil)
      expect(offer2.state).to eq 'sent'
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

  context 'reference_id' do
    it 'generates a reference id when creating the object' do
      expect(offer.reference_id).to_not be_nil
    end
  end
end
