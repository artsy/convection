# frozen_string_literal: true

require 'rails_helper'

describe Api::ConsignmentsController, type: :controller do
  before do
    allow_any_instance_of(Api::ConsignmentsController).to receive(
      :require_authentication
    )
    allow_any_instance_of(Api::ConsignmentsController).to receive(
      :fetch_sale_artworks_with_price
    ).and_return([artwork_id: 1, price: 2])
  end

  describe '#update' do
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
    let(:submission) do
      Fabricate(
        :submission,
        state: 'approved',
        artist_id: 'artistId',
        consigned_partner_submission_id: consignment.id
      )
    end
    let(:consignment) do
      Fabricate(
        :partner_submission,
        state: 'open',
        partner: partner,
        sale_price_cents: 50
      )
    end
    let(:offer) do
      Fabricate(
        :offer,
        state: 'sent',
        partner_submission: consignment,
        offer_type: 'purchase'
      )
    end

    context 'when artwork submission exist' do
      before do
        submission.update!(source_artwork_id: '1')
        consignment.update!(accepted_offer: offer)
      end

      it 'returns ok, and update consignment price' do
        put :update_price, params: { sale_id: '1' }
        expect(response.body).to eq("{\"result\":\"ok\"}")
        expect(submission.consigned_partner_submission.sale_price_cents).to eq 2
      end
    end

    context 'when artwork submission do not exist' do
      before do
        submission.update!(source_artwork_id: nil)
        consignment.update!(accepted_offer: offer)
      end

      it 'returns ok, and do not update consignment price' do
        put :update_price, params: { sale_id: '1' }
        expect(response.body).to eq("{\"result\":\"ok\"}")
        expect(consignment.sale_price_cents).to eq 50
      end
    end
  end
end
