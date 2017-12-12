require 'rails_helper'

describe 'admin/offers/new.html.erb', type: :feature do
  context 'with a submission' do
    let(:submission) { Fabricate(:submission) }
    let(:partner) { Fabricate(:partner, name: 'First Partner') }
    let(:partner) { Fabricate(:partner, name: 'Second Partner') }

    before do
      allow_any_instance_of(Admin::OffersController).to receive(:require_artsy_authentication)
      page.visit "/admin/offers/new?submission_id=#{submission.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content('New Offer')
      expect(page).to have_content("Submission ##{submission.id}")
    end
  end
end
