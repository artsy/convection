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
          expect(controller.flash[:error]).to include("Couldn't find Submission without an ID")
          expect(response).to render_template(:new_step_1)
        end.to_not change(Offer, :count)
      end
    end

    describe '#index' do
      before do
        @partner1 = Fabricate(:partner, name: 'Gagosian Gallery')
        partner2 = Fabricate(:partner, name: 'Heritage Auctions')
        @offer1 = Fabricate(:offer,
                            state: 'sent',
                            partner_submission: Fabricate(:partner_submission,
                                                          partner: @partner1,
                                                          submission: Fabricate(:submission, user_email: 'michael@bluth.com')),
                            offer_type: 'purchase',
                            price_cents: 100_00)
        @offer2 = Fabricate(:offer,
                            state: 'sent',
                            partner_submission: Fabricate(:partner_submission,
                                                          partner: @partner1,
                                                          submission: Fabricate(:submission, user_email: 'michael@bluth.com')),
                            offer_type: 'purchase',
                            price_cents: 200_00)
        @offer3 = Fabricate(:offer,
                            state: 'sent',
                            partner_submission: Fabricate(:partner_submission,
                                                          partner: @partner1,
                                                          submission: Fabricate(:submission, user_email: 'lucille@bluth.com')),
                            offer_type: 'purchase',
                            price_cents: 300_00)
        @offer4 = Fabricate(:offer,
                            state: 'sent',
                            partner_submission: Fabricate(:partner_submission,
                                                          partner: partner2,
                                                          submission: Fabricate(:submission, user_email: 'lucille@bluth.com')),
                            offer_type: 'auction consignment',
                            high_estimate_cents: 400_00)
        @offer5 = Fabricate(:offer,
                            state: 'rejected',
                            partner_submission: Fabricate(:partner_submission,
                                                          partner: partner2,
                                                          submission: Fabricate(:submission, user_email: 'lucille@bluth.com')),
                            offer_type: 'purchase',
                            price_cents: 500_00)
      end

      it 'returns the first two offers on the first page' do
        get :index, params: { page: 1, size: 2 }
        expect(controller.offers.count).to eq 2
      end

      it 'paginates correctly' do
        get :index, params: { page: 3, size: 2 }
        expect(controller.offers.count).to eq 1
      end

      describe '#sorting and filtering' do
        it 'allows you to filter by state = sent' do
          get :index, params: { state: 'sent' }
          expect(controller.offers.pluck(:id)).to eq [@offer4.id, @offer3.id, @offer2.id, @offer1.id]
        end

        it 'allows you to filter by state = rejected' do
          get :index, params: { state: 'rejected' }
          expect(controller.offers.pluck(:id)).to eq [@offer5.id]
        end

        it 'allows you to sort by user email' do
          get :index, params: { sort: 'submissions.user_email', direction: 'asc' }
          expect(controller.offers.pluck(:id)).to eq [@offer3.id, @offer4.id, @offer5.id, @offer1.id, @offer2.id]
        end

        it 'allows you to sort by price_cents' do
          get :index, params: { sort: 'price_cents', direction: 'desc' }
          expect(controller.offers.pluck(:id)).to eq [@offer4.id, @offer5.id, @offer3.id, @offer2.id, @offer1.id]
        end

        it 'allows you to filter by state and sort by price_cents' do
          get :index, params: { sort: 'price_cents', direction: 'desc', state: 'sent' }
          expect(controller.offers.pluck(:id)).to eq [@offer4.id, @offer3.id, @offer2.id, @offer1.id]
        end

        it 'allows you to filter by state, search for partner, and sort by price_cents' do
          get :index, params: { sort: 'price_cents', direction: 'desc', state: 'sent', partner: @partner1.id }
          expect(controller.offers.pluck(:id)).to eq [@offer3.id, @offer2.id, @offer1.id]
        end

        it 'allows you to filter by state, search for partner, and sort by date' do
          get :index, params: { sort: 'offers.created_at', direction: 'desc', state: 'sent', partner: @partner1.id }
          expect(controller.offers.pluck(:id)).to eq [@offer3.id, @offer2.id, @offer1.id]
        end
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
        put :update, params: { id: offer.id, offer: { high_estimate_dollars: 300, notes: 'Adding some notes to the offer.' } }
        expect(response).to redirect_to(admin_offer_url(offer))
        expect(offer.reload.high_estimate_cents).to eq 30_000
        expect(offer.notes).to eq 'Adding some notes to the offer.'
      end

      it 'allows you to update every param for an auction consignment' do
        auction_offer = Fabricate(:offer, offer_type: 'auction consignment')
        new_params = {
          low_estimate_dollars: 10_000,
          high_estimate_dollars: 50_000,
          commission_percent_whole: 10.0,
          sale_name: 'Fun sale',
          sale_date: Date.new(2017, 10, 1),
          currency: 'GBP',
          photography_dollars: 10_000,
          shipping_dollars: 20_000,
          insurance_dollars: 1_000,
          insurance_percent_whole: 12.0,
          other_fees_dollars: 2_000,
          other_fees_percent_whole: 11.0,
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
          price_dollars: 10_000,
          commission_percent_whole: 10.0,
          currency: 'GBP',
          photography_dollars: 10_000,
          shipping_dollars: 20_000,
          insurance_dollars: 1_000,
          insurance_percent_whole: 12.0,
          other_fees_dollars: 2_000,
          other_fees_percent_whole: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: purchase_offer.id,
          offer: new_params
        }
        expect(purchase_offer.reload).to have_attributes(new_params)
      end

      it 'allows you to update every param for a retail offer' do
        retail_offer = Fabricate(:offer, offer_type: 'retail')
        new_params = {
          price_dollars: 10_000,
          commission_percent_whole: 10.0,
          sale_period_start: Date.new(2017, 1, 1),
          sale_period_end: Date.new(2017, 10, 1),
          currency: 'GBP',
          photography_dollars: 10_000,
          shipping_dollars: 20_000,
          insurance_dollars: 1_000,
          insurance_percent_whole: 12.0,
          other_fees_dollars: 2_000,
          other_fees_percent_whole: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: retail_offer.id,
          offer: new_params
        }
        expect(retail_offer.reload).to have_attributes(new_params)
      end

      it 'allows you to un-set fields' do
        retail_offer = Fabricate(:offer, offer_type: 'retail', insurance_dollars: 10, insurance_percent_whole: 12)
        put :update, params: {
          id: retail_offer.id,
          offer: { insurance_dollars: nil, insurance_percent_whole: nil }
        }
        expect(retail_offer.reload.insurance_cents).to eq nil
        expect(retail_offer.reload.insurance_percent_whole).to eq nil
      end

      it 'remains on the edit view and shows an error on failure' do
        put :update, params: { id: offer.id, offer: { offer_type: 'bogus type' } }
        expect(response).to render_template(:edit)
        expect(controller.flash[:error]).to include('Validation failed: Offer type is not included in the list')
      end

      it 'allows you to update every param for a net price offer' do
        net_price_offer = Fabricate(:offer, offer_type: 'net price')
        new_params = {
          price_dollars: 10_000,
          sale_period_start: Date.new(2017, 1, 1),
          sale_period_end: Date.new(2017, 10, 1),
          currency: 'GBP',
          photography_dollars: 10_000,
          shipping_dollars: 20_000,
          insurance_dollars: 1_000,
          insurance_percent_whole: 12.0,
          other_fees_dollars: 2_000,
          other_fees_percent_whole: 11.0,
          notes: 'New notes.'
        }
        put :update, params: {
          id: net_price_offer.id,
          offer: new_params
        }
        expect(net_price_offer.reload).to have_attributes(new_params)
      end

      it 'remains on the edit view and shows an error on failure' do
        put :update, params: { id: offer.id, offer: { offer_type: 'bogus type' } }
        expect(response).to render_template(:edit)
        expect(controller.flash[:error]).to include('Validation failed: Offer type is not included in the list')
      end
    end
  end
end
