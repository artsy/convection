require 'rails_helper'

describe Admin::OffersController, type: :controller do
  describe 'with some partners' do
    let(:submission) { Fabricate(:submission, state: 'approved') }
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }

    before do
      allow_any_instance_of(Admin::OffersController).to receive(:require_artsy_authentication)
    end

    describe '#create' do
      it 'redirects to the edit view on success' do
        expect do
          post :create, params: { partner_id: partner.id, submission_id: submission.id, offer: { offer_type: 'purchase' } }
          expect(response).to redirect_to(admin_offer_url(Offer.last))
        end.to change(Offer, :count).by(1)
      end

      it 'remains on the new view and shows an error on failure' do
        expect do
          post :create, params: { partner_id: partner.id, offer: { offer_type: 'purchase' } }
          expect(controller.flash[:error]).to include("Couldn't find Submission with 'id'=")
          expect(response).to render_template(:new_step_1)
        end.to_not change(Offer, :count)
      end
    end

    describe '#index' do
      before do
        5.times { Fabricate(:offer, state: 'sent') }
      end
      it 'returns the first two offers on the first page' do
        get :index, params: { page: 1, size: 2 }
        expect(controller.offers.count).to eq 2
      end
      it 'paginates correctly' do
        get :index, params: { page: 3, size: 2 }
        expect(controller.offers.count).to eq 1
      end
    end

    describe '#update' do
      let(:offer) do
        Fabricate(:offer,
          offer_type: 'auction consignment',
          low_estimate_cents: 10_000,
          high_estimate_cents: 20_000,
          sale_name: 'Fun sale!')
      end

      it 'redirects to the show view on success' do
        put :update, params: { id: offer.id, offer: { high_estimate_cents: 30_000, notes: 'Adding some notes to the offer.' } }
        expect(response).to redirect_to(admin_offer_url(offer))
        expect(offer.reload.high_estimate_cents).to eq 30_000
        expect(offer.notes).to eq 'Adding some notes to the offer.'
      end

      it 'allows you to update every param for an auction consignment' do
        auction_offer = Fabricate(:offer, offer_type: 'auction consignment')
        new_params = {
          low_estimate_cents: 10_000,
          high_estimate_cents: 50_000,
          commission_percent: 10.0,
          sale_name: 'Fun sale',
          sale_date: Date.new(2017, 10, 1),
          currency: 'GBP',
          photography_cents: 10_000,
          shipping_cents: 20_000,
          insurance_cents: 1_000,
          insurance_percent: 12.0,
          other_fees_cents: 2_000,
          other_fees_percent: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: auction_offer.id,
          offer: new_params
        }
        expect(auction_offer.reload).to have_attributes(new_params)
      end

      it 'allows you to update every param for a direct purchase' do
        purchase_offer = Fabricate(:offer, offer_type: 'purchase')
        new_params = {
          price_cents: 10_000,
          commission_percent: 10.0,
          currency: 'GBP',
          photography_cents: 10_000,
          shipping_cents: 20_000,
          insurance_cents: 1_000,
          insurance_percent: 12.0,
          other_fees_cents: 2_000,
          other_fees_percent: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: purchase_offer.id,
          offer: new_params
        }
        expect(purchase_offer.reload).to have_attributes(new_params)
      end

      it 'allows you to update every param for a consignment period' do
        consignment_period_offer = Fabricate(:offer, offer_type: 'consignment period')
        new_params = {
          price_cents: 10_000,
          commission_percent: 10.0,
          sale_period_start: Date.new(2017, 1, 1),
          sale_period_end: Date.new(2017, 10, 1),
          currency: 'GBP',
          photography_cents: 10_000,
          shipping_cents: 20_000,
          insurance_cents: 1_000,
          insurance_percent: 12.0,
          other_fees_cents: 2_000,
          other_fees_percent: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: consignment_period_offer.id,
          offer: new_params
        }
        expect(consignment_period_offer.reload).to have_attributes(new_params)
      end

      it 'remains on the edit view and shows an error on failure' do
        put :update, params: { id: offer.id, offer: { offer_type: 'bogus type' } }
        expect(response).to render_template(:edit)
        expect(controller.flash[:error]).to include('Validation failed: Offer type is not included in the list')
      end
    end
  end
end
