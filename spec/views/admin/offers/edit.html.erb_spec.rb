# frozen_string_literal: true

require 'rails_helper'

describe 'admin/offers/edit.html.erb', type: :feature do
  context 'with an offer' do
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
    let(:submission) { Fabricate(:submission) }
    let(:partner_submission) do
      Fabricate(:partner_submission, partner: partner, submission: submission)
    end

    before do
      allow_any_instance_of(Admin::OffersController).to receive(
        :require_artsy_authentication
      )
    end

    describe 'auction consignment offer' do
      let(:offer) do
        Fabricate(
          :offer,
          offer_type: 'auction consignment',
          partner_submission: partner_submission
        )
      end
      before { page.visit "/admin/offers/#{offer.id}/edit" }

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content(
          "Auction consignment offer for Submission ##{
            submission.id
          } by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
        expect(page).to have_content('Partner Info')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Low estimate')
        expect(page).to have_content('High estimate')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale name')
        expect(page).to have_content('Sale date')
        expect(page).to_not have_content('Price')
      end
    end

    describe 'purchase offer' do
      let(:offer) do
        Fabricate(
          :offer,
          offer_type: 'purchase', partner_submission: partner_submission
        )
      end

      before { page.visit "/admin/offers/#{offer.id}/edit" }

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content(
          "Purchase offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
        expect(page).to have_content('Partner Info')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price')
        expect(page).to_not have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end
    end

    describe 'retail offer' do
      let(:offer) do
        Fabricate(
          :offer,
          offer_type: 'retail', partner_submission: partner_submission
        )
      end
      before { page.visit "/admin/offers/#{offer.id}/edit" }

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content(
          "Retail offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
        expect(page).to have_content('Partner Info')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Retail price')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end
    end

    describe 'net price offer' do
      let(:offer) do
        Fabricate(
          :offer,
          offer_type: 'net price', partner_submission: partner_submission
        )
      end
      before { page.visit "/admin/offers/#{offer.id}/edit" }

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content(
          "Net price offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
        expect(page).to have_content('Partner Info')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Net sale price')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
        expect(page).to_not have_content('Commission %')
      end
    end
  end
end
