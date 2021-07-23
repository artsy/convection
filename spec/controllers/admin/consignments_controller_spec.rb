# frozen_string_literal: true

require 'rails_helper'

describe Admin::ConsignmentsController, type: :controller do
  before do
    allow_any_instance_of(Admin::ConsignmentsController).to receive(
      :require_artsy_authentication
    )
  end

  describe '#index' do
    before do
      @artist = {id: 'artistId', name: 'Banksy'}
      @partner1 = Fabricate(:partner, name: 'Gagosian Gallery')
      partner2 = Fabricate(:partner, name: 'Heritage Auctions')
      @consignment1 =
        Fabricate(
          :partner_submission,
          state: 'open',
          submission: Fabricate(:submission, state: 'approved', artist_id: @artist[:id]),
          partner: @partner1,
          sale_price_cents: 100_000
        )
      @consignment2 =
        Fabricate(
          :partner_submission,
          state: 'open',
          submission: Fabricate(:submission, state: 'approved', artist_id: @artist[:id]),
          partner: @partner1,
          sale_price_cents: 200_000
        )
      @consignment3 =
        Fabricate(
          :partner_submission,
          state: 'bought in',
          submission: Fabricate(:submission, state: 'approved', artist_id: 'someArtistId'),
          partner: @partner1,
          sale_price_cents: 300_000
        )
      @consignment4 =
        Fabricate(
          :partner_submission,
          state: 'open',
          submission: Fabricate(:submission, state: 'approved'),
          partner: partner2
        )
      @consignment5 =
        Fabricate(
          :partner_submission,
          state: 'open',
          submission: Fabricate(:submission, state: 'approved'),
          partner: partner2
        )
      @consignment6 =
        Fabricate(
          :partner_submission,
          state: 'withdrawn - Pre-Launch',
          submission: Fabricate(:submission, state: 'approved'),
          partner: partner2
        )
      @consignment7 =
        Fabricate(
          :partner_submission,
          state: 'withdrawn - Post-Launch',
          submission: Fabricate(:submission, state: 'approved'),
          partner: partner2
        )

      @consignment1.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'purchase'
          )
      )
      @consignment2.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'purchase'
          )
      )
      @consignment3.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'net price'
          )
      )
      @consignment4.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'auction consignment'
          )
      )
      @consignment5.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'retail'
          )
      )
      @consignment6.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'purchase'
          )
      )
      @consignment7.update!(
        accepted_offer:
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission: @consignment1,
            offer_type: 'purchase'
          )
      )
    end

    it 'returns the first two consignments on the first page' do
      get :index, params: { page: 1, size: 2 }
      expect(controller.consignments.count).to eq 2
    end

    it 'paginates correctly' do
      get :index, params: { page: 4, size: 2 }
      expect(controller.consignments.count).to eq 1
    end

    describe '#sorting and filtering' do
      it 'allows you to filter by state = open' do
        get :index, params: { state: 'open' }
        expect(controller.consignments.pluck(:id)).to eq [
             @consignment5.id,
             @consignment4.id,
             @consignment2.id,
             @consignment1.id
           ]
      end

      it 'allows you to filter by state = bought in' do
        get :index, params: { state: 'bought in' }
        expect(controller.consignments.pluck(:id)).to eq [@consignment3.id]
      end

      it 'allows you to filter by state = withdrawn - Pre-Launch' do
        get :index, params: { state: 'withdrawn - Pre-Launch' }
        expect(controller.consignments.pluck(:id)).to eq [@consignment6.id]
      end

      it 'allows you to filter by state = withdrawn - Post-Launch' do
        get :index, params: { state: 'withdrawn - Post-Launch' }
        expect(controller.consignments.pluck(:id)).to eq [@consignment7.id]
      end

      it 'allows you to sort by offer type' do
        get :index, params: { sort: 'offers.offer_type', direction: 'asc' }
        expect(controller.consignments.pluck(:id)).to eq(
          [
            @consignment4.id,
            @consignment3.id,
            @consignment7.id,
            @consignment6.id,
            @consignment2.id,
            @consignment1.id,
            @consignment5.id
          ]
        )
      end

      it 'allows you to sort by partner name' do
        get :index, params: { sort: 'partners.name', direction: 'desc' }
        expect(controller.consignments.pluck(:id)).to eq(
          [
            @consignment7.id,
            @consignment6.id,
            @consignment5.id,
            @consignment4.id,
            @consignment3.id,
            @consignment2.id,
            @consignment1.id
          ]
        )
      end

      it 'allows you to sort by sale_price_cents' do
        get :index, params: { sort: 'sale_price_cents', direction: 'desc' }
        expect(controller.consignments.pluck(:id)).to eq(
          [
            @consignment4.id,
            @consignment5.id,
            @consignment6.id,
            @consignment7.id,
            @consignment3.id,
            @consignment2.id,
            @consignment1.id
          ]
        )
      end

      it 'allows you to filter by state and sort by sale_price_cents' do
        get :index,
            params: {
              sort: 'sale_price_cents', direction: 'desc', state: 'open'
            }
        expect(controller.consignments.pluck(:id)).to eq [
             @consignment4.id,
             @consignment5.id,
             @consignment2.id,
             @consignment1.id
           ]
      end

      it 'allows you to search for partner and sort by sale_price_cents' do
        get :index,
            params: {
              sort: 'sale_price_cents', direction: 'desc', partner: @partner1.id
            }
        expect(controller.consignments.pluck(:id)).to eq [
             @consignment3.id,
             @consignment2.id,
             @consignment1.id
           ]
      end

      it 'allows you to search for artist and sort by sale_price_cents' do
        get :index,
            params: {
              sort: 'sale_price_cents', direction: 'desc', artist: @artist[:id]
            }
        expect(controller.consignments.pluck(:id)).to eq [
             @consignment2.id,
             @consignment1.id
           ]
      end
    end
  end
end
