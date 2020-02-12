# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe OffersHelper, type: :helper do
  context 'reviewed_byline' do
    before do
      stub_gravity_root
      stub_gravity_user
    end

    it 'shows the correct label for a rejected offer' do
      offer = Fabricate(:offer, state: 'rejected', rejected_by: 'userid')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by Jon Jonson.'
    end

    it 'shows the correct label for a rejected offer with a rejection_reason' do
      offer =
        Fabricate(
          :offer,
          state: 'rejected',
          rejected_by: 'userid',
          rejection_reason: 'Low estimate'
        )
      expect(
        helper.reviewed_byline(offer)
      ).to eq 'Rejected by Jon Jonson. Low estimate'
    end

    it 'shows the correct label for a rejected offer with a rejection_reason and rejection_note' do
      offer =
        Fabricate(
          :offer,
          state: 'rejected',
          rejected_by: 'userid',
          rejection_reason: 'Other',
          rejection_note: 'User not a fan of this partner.'
        )
      expect(
        helper.reviewed_byline(offer)
      ).to eq 'Rejected by Jon Jonson. Other: User not a fan of this partner.'
    end

    it 'shows the correct label for a rejected offer with no user' do
      offer = Fabricate(:offer, state: 'rejected')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by .'
    end
  end

  context 'display_fields' do
    it 'returns an array containing only the fields that are present, with minimal fields present' do
      offer =
        Fabricate(
          :offer,
          offer_type: 'auction consignment',
          price_cents: nil,
          commission_percent: 0.1
        )
      expect(helper.display_fields(offer)).to eq('Commission' => '10.0%')
    end

    it 'does not include empty values' do
      offer =
        Fabricate(
          :offer,
          offer_type: 'auction consignment',
          price_cents: nil,
          sale_name: '',
          commission_percent: 0.1,
          low_estimate_cents: 10_000,
          high_estimate_cents: 40_000,
          sale_date: Date.new(2_018, 10, 30)
        )
      expect(helper.display_fields(offer)).to eq(
        'Estimate' => 'USD $100 - 400',
        'Sale Date' => 'Oct 30, 2018',
        'Commission' => '10.0%'
      )
    end

    it 'returns an array containing only the present fields with many fields present' do
      offer =
        Fabricate(
          :offer,
          offer_type: 'auction consignment',
          price_cents: nil,
          commission_percent: 0.1,
          low_estimate_cents: 10_000,
          high_estimate_cents: 40_000,
          sale_date: Date.new(2_018, 10, 30)
        )
      expect(helper.display_fields(offer)).to eq(
        'Estimate' => 'USD $100 - 400',
        'Sale Date' => 'Oct 30, 2018',
        'Commission' => '10.0%'
      )
    end
  end

  context 'formatted_offer_type' do
    it 'returns the correct string for an auction consignment offer' do
      offer = double('offer', offer_type: 'auction consignment')
      expect(helper.formatted_offer_type(offer)).to eq 'Auction consignment'
    end

    it 'returns the correct string for a retail offer' do
      offer = double('offer', offer_type: 'retail')
      expect(
        helper.formatted_offer_type(offer)
      ).to eq 'Private Sale: Retail Price'
    end

    it 'returns the correct string for a net price offer' do
      offer = double('offer', offer_type: 'net price')
      expect(helper.formatted_offer_type(offer)).to eq 'Private Sale: Net Price'
    end

    it 'returns the correct string for a direct purchase offer' do
      offer = double('offer', offer_type: 'purchase')
      expect(helper.formatted_offer_type(offer)).to eq 'Outright purchase'
    end
  end

  context 'offer_type_description' do
    it 'returns the correct string for an auction consignment offer' do
      offer = double('offer', offer_type: 'auction consignment')
      expect(
        helper.offer_type_description(offer)
      ).to include 'This work will be offered in an auction.'
    end

    it 'returns the correct string for a retail offer' do
      offer = double('offer', offer_type: 'retail')
      expect(
        helper.offer_type_description(offer)
      ).to include 'This work will be offered privately'
    end

    it 'returns the correct string for a net price offer' do
      offer = double('offer', offer_type: 'net price')
      expect(
        helper.offer_type_description(offer)
      ).to include 'This work will be offered privately'
    end

    it 'returns the correct string for a direct purchase offer' do
      offer = double('offer', offer_type: 'purchase')
      expect(
        helper.offer_type_description(offer)
      ).to include 'The work will be purchased directly from you by the ' \
                'partner for the specified price.'
    end
  end

  context 'estimate_display' do
    it 'works for an offer in USD' do
      offer =
        double(
          'offer',
          low_estimate_cents: 10_000,
          high_estimate_cents: 30_000,
          currency: 'USD'
        )
      expect(helper.estimate_display(offer)).to eq 'USD $100 - 300'
    end

    it 'works for EUR' do
      offer =
        double(
          'offer',
          low_estimate_cents: 10_000,
          high_estimate_cents: 30_000,
          currency: 'EUR'
        )
      expect(helper.estimate_display(offer)).to eq 'EUR €100 - 300'
    end

    it 'works when there is only a low estimate' do
      offer =
        double(
          'offer',
          low_estimate_cents: 10_000, high_estimate_cents: nil, currency: 'EUR'
        )
      expect(helper.estimate_display(offer)).to eq 'EUR €100'
    end

    it 'works when there is only a high estimate' do
      offer =
        double(
          'offer',
          low_estimate_cents: nil, high_estimate_cents: 30_000, currency: 'EUR'
        )
      expect(helper.estimate_display(offer)).to eq 'EUR €300'
    end

    it 'returns nil if both values are nil' do
      offer =
        double(
          'offer',
          low_estimate_cents: nil, high_estimate_cents: nil, currency: 'EUR'
        )
      expect(helper.estimate_display(offer)).to eq nil
    end
  end

  context 'price_display' do
    it 'works for a price in USD' do
      offer = double('offer', price_cents: 10_000, currency: 'USD')
      expect(
        helper.price_display(offer.currency, offer.price_cents)
      ).to eq 'USD $100'
    end

    it 'works for a price in CAD' do
      offer = double('offer', price_cents: 10_000, currency: 'CAD')
      expect(
        helper.price_display(offer.currency, offer.price_cents)
      ).to eq 'CAD $100'
    end

    it 'returns nil if there is no price_cents' do
      offer = double('offer', price_cents: nil, currency: 'USD')
      expect(helper.price_display(offer.currency, offer.price_cents)).to eq nil
    end
  end

  context 'sale_period_display' do
    it 'works for an offer with a sale period' do
      offer =
        double(
          'offer',
          sale_period_start: Date.new(2_017, 1, 10),
          sale_period_end: Date.new(2_017, 3, 10)
        )
      expect(
        helper.sale_period_display(offer)
      ).to eq 'Jan 10, 2017 - Mar 10, 2017'
    end

    it 'works for an offer with only a sale_period_start' do
      offer =
        double(
          'offer',
          sale_period_start: Date.new(2_017, 1, 10), sale_period_end: nil
        )
      expect(helper.sale_period_display(offer)).to eq 'Starts Jan 10, 2017'
    end

    it 'works for an offer with only a sale_period_end' do
      offer =
        double(
          'offer',
          sale_period_start: nil, sale_period_end: Date.new(2_017, 3, 10)
        )
      expect(helper.sale_period_display(offer)).to eq 'Ends Mar 10, 2017'
    end

    it 'works for an offer with no sale period' do
      offer = double('offer', sale_period_start: nil, sale_period_end: nil)
      expect(helper.sale_period_display(offer)).to eq nil
    end
  end

  context 'sale_date_display' do
    it 'works for an offer with a sale_date' do
      offer = double('offer', sale_date: Date.new(2_017, 1, 10))
      expect(helper.sale_date_display(offer)).to eq 'Jan 10, 2017'
    end

    it 'returns nil if there is no sale_date' do
      offer = double('offer', sale_date: nil)
      expect(helper.sale_date_display(offer)).to eq nil
    end
  end

  context 'commission_display' do
    it 'works for an offer with a commission_percent' do
      offer = double('offer', commission_percent: 0.12)
      expect(helper.commission_display(offer)).to eq '12.0%'
    end

    it 'works for an offer with a 0.14 comission_percent' do
      offer = double('offer', commission_percent: 0.14)
      expect(helper.commission_display(offer)).to eq '14.0%'
    end

    it 'works for an offer with a 0 comission_percent' do
      offer = double('offer', commission_percent: 0)
      expect(helper.commission_display(offer)).to eq '0%'
    end

    it 'returns nil if the offer has no commission_percent' do
      offer = double('offer', commission_percent: nil)
      expect(helper.commission_display(offer)).to eq nil
    end
  end

  context 'shipping_display' do
    it 'works for an offer with shipping_cents' do
      offer = double('offer', shipping_cents: 12_000, currency: 'USD')
      expect(helper.shipping_display(offer)).to eq 'USD $120.00'
    end

    it 'returns nil if the offer has no shipping_cents' do
      offer = double('offer', shipping_cents: nil, currency: 'USD')
      expect(helper.shipping_display(offer)).to eq nil
    end
  end

  context 'photography_display' do
    it 'works for an offer with photography_cents' do
      offer = double('offer', photography_cents: 12_000, currency: 'USD')
      expect(helper.photography_display(offer)).to eq 'USD $120.00'
    end

    it 'returns nil if the offer has no photography_cents' do
      offer = double('offer', photography_cents: nil, currency: 'USD')
      expect(helper.photography_display(offer)).to eq nil
    end
  end

  context 'insurance_display' do
    it 'works if the offer has an insurance_cents' do
      offer =
        double(
          'offer',
          insurance_cents: 12_000, insurance_percent: nil, currency: 'USD'
        )
      expect(helper.insurance_display(offer)).to eq 'USD $120.00'
    end

    it 'works if the offer has an insurance_percent' do
      offer =
        double(
          'offer',
          insurance_cents: nil, insurance_percent: 0.12, currency: 'USD'
        )
      expect(helper.insurance_display(offer)).to eq '12.0%'
    end

    it 'returns nil if the offer has no insurance' do
      offer =
        double(
          'offer',
          insurance_percent: nil, insurance_cents: nil, currency: 'USD'
        )
      expect(helper.insurance_display(offer)).to eq nil
    end
  end

  context 'other_fees_display' do
    it 'works if the offer has an other_fees_cents' do
      offer = double('offer', other_fees_cents: 12_000, currency: 'USD')
      expect(helper.other_fees_display(offer)).to eq 'USD $120.00'
    end

    it 'works if the offer has an other_fees_percent' do
      offer =
        double(
          'offer',
          other_fees_cents: nil, other_fees_percent: 0.12, currency: 'USD'
        )
      expect(helper.other_fees_display(offer)).to eq '12.0%'
    end

    it 'returns nil if the offer has no other fees' do
      offer =
        double(
          'offer',
          other_fees_percent: nil, other_fees_cents: nil, currency: 'USD'
        )
      expect(helper.other_fees_display(offer)).to eq nil
    end
  end
end
