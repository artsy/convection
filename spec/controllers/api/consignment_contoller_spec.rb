# frozen_string_literal: true

require 'rails_helper'

describe Api::ConsignmentsController, type: :controller do
  before do
    allow_any_instance_of(Api::ConsignmentsController).to receive(
      :require_authentication
    )
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
  end
end
