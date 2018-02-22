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

  describe 'Dollarize' do
    it 'has all of the correct attributes' do
      expect(Offer.new.attributes.keys).to include(
        'low_estimate',
        'low_estimate_cents',
        'high_estimate',
        'high_estimate_cents',
        'photography',
        'photography_cents',
        'shipping',
        'shipping_cents',
        'insurance',
        'insurance_cents',
        'other_fees',
        'other_fees_cents'
      )
    end

    it 'converts _cents attribute to a currency display' do
      offer = Offer.new(low_estimate: 100)
      expect(offer.low_estimate_cents).to eq 100_00
      expect(offer.low_estimate).to eq 100
      expect(offer.low_estimate_display).to eq '$100'
    end
  end

  describe 'Percentize' do
    it 'has all of the correct attributes' do
      expect(Offer.new.attributes.keys).to include(
        'commission_percent',
        'commission_percent_whole',
        'insurance_percent',
        'insurance_percent_whole',
        'other_fees_percent',
        'other_fees_percent_whole'
      )
    end

    it 'converts _cents attribute to a currency display' do
      offer = Offer.new(commission_percent_whole: 12.25)
      expect(offer.commission_percent).to eq 0.1225
      expect(offer.commission_percent_whole).to eq 12.25
    end
  end
end
