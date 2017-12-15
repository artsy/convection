require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/offers/show.html.erb', type: :feature do
  context 'always' do
    let(:submission) { Fabricate(:submission) }
    let(:partner) { Fabricate(:partner) }
    let(:partner_submission) { Fabricate(:partner_submission, submission: submission, partner: partner) }
    let(:offer) { Fabricate(:offer, partner_submission: partner_submission, offer_type: 'purchase', state: 'draft') }

    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)

      stub_gravity_root
      stub_gravity_user(id: submission.user_id)
      stub_gravity_user_detail(id: submission.user_id)

      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      gravql_artists_response = {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol' },
            { id: 'artist2', name: 'Kara Walker' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )
      page.visit "/admin/offers/#{offer.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Offer ##{offer.reference_id}")
      expect(page).to have_content('Offer type purchase')
    end

    it 'lets you delete the offer' do
      stub_gravity_artist(id: submission.artist_id)
      expect(page).to have_selector('#offer-delete-button')
      click_link('offer-delete-button')
      expect(page.current_path).to eq("/admin/submissions/#{submission.id}")
      expect(page).to have_content('Offer deleted')
    end

    it 'does not display the delete button if not in draft state' do
      offer.update_attributes!(state: 'sent')
      page.visit "/admin/offers/#{offer.id}"
      expect(page).to_not have_selector('#offer-delete-button')
    end

    describe 'save & send' do
      it 'shows the save & send button when offer is in draft state' do
        offer.update_attributes!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Save & Send')
      end

      it 'does not show the save & send button after the offer has been sent' do
        offer.update_attributes!(state: 'sent')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to_not have_content('Save & Send')
      end

      it 'allows you to save the offer' do
        stub_gravity_artist(id: submission.artist_id)
        offer.update_attributes!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        click_link('Save & Send')
        expect(page).to have_content("Offer ##{offer.reference_id} (sent)")
        expect(page).to_not have_content('Save & Send')
      end
    end
  end
end
