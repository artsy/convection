require 'rails_helper'

describe 'admin/offers/edit.html.erb', type: :feature do
  context 'with an offer' do
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
    let(:submission) { Fabricate(:submission) }
    let(:partner_submission) { Fabricate(:partner_submission, partner: partner, submission: submission) }

    before do
      allow_any_instance_of(Admin::OffersController).to receive(:require_artsy_authentication)
    end

    describe 'auction consignment offer' do
      let(:offer) { Fabricate(:offer, offer_type: 'auction consignment', partner_submission: partner_submission) }
      before do
        page.visit "/admin/offers/#{offer.id}/edit"
      end

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content("Auction consignment offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Low estimate cents')
        expect(page).to have_content('High estimate cents')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale name')
        expect(page).to have_content('Sale date')
        expect(page).to_not have_content('Price cents')
      end
    end

    describe 'purchase offer' do
      let(:offer) { Fabricate(:offer, offer_type: 'purchase', partner_submission: partner_submission) }

      before do
        page.visit "/admin/offers/#{offer.id}/edit"
      end

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content("Purchase offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price cents')
        expect(page).to have_content('Commission %')
        expect(page).to_not have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end
    end

    describe 'consignment period offer' do
      let(:offer) { Fabricate(:offer, offer_type: 'consignment period', partner_submission: partner_submission) }
      before do
        page.visit "/admin/offers/#{offer.id}/edit"
      end

      it 'displays the page title and content' do
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content("Consignment period offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price cents')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end
    end
  end
end
