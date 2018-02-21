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
      expect(Offer.new(offer_type: 'consignment period')).to_not be_valid
      expect(Offer.new(offer_type: 'retail')).to be_valid
      expect(Offer.new(offer_type: 'net price')).to be_valid
    end
  end

  context 'currency' do
    it 'allows only certain currencies' do
      expect(Offer.new(currency: 'blah')).not_to be_valid
      expect(Offer.new(currency: 'USD')).to be_valid
      expect(Offer.new(currency: 'EUR')).to be_valid
      expect(Offer.new(currency: 'GBP')).to be_valid
      expect(Offer.new(currency: 'HKD')).to be_valid
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

  context 'locked?' do
    it 'returns true if this offer is not the accepted_offer and the partner submission is consigned' do
      ps = offer.partner_submission
      consigned_offer = Fabricate(:offer, partner_submission: ps)
      OfferService.consign!(consigned_offer)
      expect(offer.locked?).to eq true
      expect(consigned_offer.locked?).to eq false
    end

    it 'returns false if the submission has not been consigned at all' do
      expect(offer.locked?).to eq false
    end

    it 'returns false if this offer is the accepted_offer' do
      OfferService.consign!(offer)
      expect(offer.locked?).to eq false
    end
  end

  context 'rejection_reason' do
    it 'allows only certain rejection reasons' do
      expect(Offer.new(rejection_reason: 'blah')).not_to be_valid
      expect(Offer.new(rejection_reason: 'Other')).to be_valid
      expect(Offer.new(rejection_reason: 'Low estimate')).to be_valid
    end
  end

  context 'searching' do
    before do
      partner1 = Fabricate(:partner, name: 'Gagosian')
      partner2 = Fabricate(:partner, name: 'Heritage Auctions')
      @offer1 = Fabricate(:offer, partner_submission: Fabricate(:partner_submission, partner: partner1))
      @offer2 = Fabricate(:offer, partner_submission: Fabricate(:partner_submission, partner: partner1))
      @offer3 = Fabricate(:offer, partner_submission: Fabricate(:partner_submission, partner: partner2))
    end

    it 'allows you to search for offers by reference_id' do
      results = Offer.search(@offer1.reference_id)
      expect(results.length).to eq 1
      expect(results.first.id).to eq @offer1.id
    end

    it 'allows you to search for offers by partner name' do
      results = Offer.search('Gag')
      expect(results.length).to eq 2
      expect(results.map(&:id)).to eq [@offer1.id, @offer2.id]
    end
  end
end
