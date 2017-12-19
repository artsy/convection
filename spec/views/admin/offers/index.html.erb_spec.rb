require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/offers/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)

      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      gravql_artists_response = {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol' }
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

      page.visit '/admin/offers'
    end

    it 'displays the page title' do
      expect(page).to have_content('Offers')
      expect(page).not_to have_selector('.list-group-item')
    end

    it 'displays zeros for the counts' do
      expect(page).to have_content('All 0')
      expect(page).to have_content('Draft 0')
      expect(page).to have_content('Sent 0')
      expect(page).to have_content('Accepted 0')
      expect(page).to have_content('Rejected 0')
    end

    context 'with some offers' do
      before do
        3.times { Fabricate(:offer, state: 'sent') }
        page.visit '/admin/offers'
      end

      it 'displays all of the offers' do
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 3)
      end

      it 'lets you click an offer' do
        offer = Offer.first
        stub_gravity_root
        stub_gravity_user(id: offer.submission.user_id)
        stub_gravity_user_detail(id: offer.submission.user_id)
        stub_gravity_artist(id: offer.submission.artist_id)

        within(:css, ".list-item--offer[data-id='#{offer.id}']") do
          click_link('View')
        end
        expect(page).to have_content("Offer ##{offer.reference_id} (sent)")
        expect(page).to have_content('Offer Lapsed')
      end

      it 'shows the counts of offers' do
        expect(page).to have_content('All 3')
        expect(page).to have_content('Draft 0')
        expect(page).to have_content('Sent 3')
        expect(page).to have_content('Accepted 0')
        expect(page).to have_content('Rejected 0')
      end

      it 'lets you click a filter option' do
        click_link('Sent')
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 3)
        expect(current_path).to eq '/admin/offers'
      end
    end

    context 'with a variety of offers' do
      before do
        3.times { Fabricate(:offer, state: 'sent') }
        Fabricate(:offer, state: 'accepted')
        Fabricate(:offer, state: 'rejected')
        Fabricate(:offer, state: 'draft')
        page.visit '/admin/offers'
      end

      it 'shows the correct counts' do
        expect(page).to have_content('All 6')
        expect(page).to have_content('Draft 1')
        expect(page).to have_content('Sent 3')
        expect(page).to have_content('Accepted 1')
        expect(page).to have_content('Rejected 1')
      end

      it 'lets you click into a filter option' do
        click_link('Accepted')
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 1)
      end

      it 'filters by changing the url' do
        page.visit('/admin/offers?state=rejected')
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 1)
      end
    end
  end
end
