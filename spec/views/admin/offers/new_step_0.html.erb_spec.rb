require 'rails_helper'

describe 'admin/offers/new_step_0.html.erb', type: :feature do
  context 'with a submission' do
    let(:submission) { Fabricate(:submission) }
    let(:partner) { Fabricate(:partner, name: 'First Partner') }
    let(:partner) { Fabricate(:partner, name: 'Second Partner') }

    before do
      allow_any_instance_of(Admin::OffersController).to receive(:require_artsy_authentication)
      page.visit "/admin/offers/new_step_0?submission_id=#{submission.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content('New Offer')
      expect(page).to have_content("Submission ##{submission.id}")
    end

    it 'displays an error message if no partner is selected' do
      expect(find('input#offer_type_auction_consignment')).to be_checked
      click_button('Next')
      expect(page).to have_content('Offer requires type, submission, and partner.')
    end

    it 'keeps the offer type selected when an error is shown' do
      choose('offer_type_purchase')
      click_button('Next')
      expect(page).to have_content('Offer requires type, submission, and partner.')
      expect(find('input#offer_type_purchase')).to be_checked
    end
  end
end
