require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/consignments/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)

      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      page.visit admin_consignments_path
    end

    it 'displays the page title' do
      expect(page).to have_content('Consignments')
      expect(page).not_to have_selector('.list-group-item')
    end

    it 'displays zeros for the counts' do
      expect(page).to have_content('All 0')
      expect(page).to have_content('Unconfirmed 0')
      expect(page).to have_content('Signed 0')
      expect(page).to have_content('Sold 0')
      expect(page).to have_content('Bought in 0')
      expect(page).to have_content('Closed 0')
    end

    context 'with some consignments' do
      before do
        3.times do
          Fabricate(:consignment, state: 'unconfirmed')
        end
        page.visit admin_consignments_path
      end

      it 'displays all of the consignments' do
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 3)
      end

      it 'lets you click a consignment' do
        consignment = PartnerSubmission.consigned.first

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

        stub_gravity_root
        stub_gravity_user(id: consignment.submission.user_id)
        stub_gravity_user_detail(id: consignment.submission.user_id)
        stub_gravity_artist(id: consignment.submission.artist_id)
        page.visit admin_consignments_path

        find(".list-item--consignment[data-id='#{consignment.id}']").click
        expect(page).to have_content("Consignment ##{consignment.reference_id} (unconfirmed)")
      end

      it 'shows the counts of consignments' do
        expect(page).to have_content('All 3')
        expect(page).to have_content('Unconfirmed 3')
        expect(page).to have_content('Signed 0')
        expect(page).to have_content('Sold 0')
        expect(page).to have_content('Bought in 0')
        expect(page).to have_content('Closed 0')
      end

      it 'lets you click a filter option' do
        click_link('Signed')
        expect(page).to have_selector('.list-group-item', count: 0)
        expect(current_url).to include admin_consignments_path(state: 'signed')
      end
    end

    context 'with a variety of consignments' do
      before do
        partner1 = Fabricate(:partner, name: 'Gagosian Gallery')
        partner2 = Fabricate(:partner, name: 'Heritage Auctions')
        3.times { Fabricate(:consignment, state: 'unconfirmed', partner: partner1) }
        Fabricate(:consignment, state: 'signed', partner: partner2)
        Fabricate(:consignment, state: 'sold', partner: partner2)
        Fabricate(:consignment, state: 'closed', partner: partner2)
        page.visit admin_consignments_path
      end

      it 'shows the correct counts' do
        expect(page).to have_content('All 6')
        expect(page).to have_content('Unconfirmed 3')
        expect(page).to have_content('Signed 1')
        expect(page).to have_content('Sold 1')
        expect(page).to have_content('Bought in 0')
        expect(page).to have_content('Closed 1')
      end

      it 'lets you click into a filter option' do
        click_link('Signed')
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 1)
      end

      it 'filters by changing the url' do
        page.visit('/admin/consignments?state=bought+in')
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 0)
      end

      it 'allows you to search by partner name' do
        fill_in('term', with: 'gallery')
        click_button('Search')
        partner_names = page.all('.list-group-item-info--partner-name').map(&:text)
        expect(partner_names.count).to eq 3
        expect(partner_names.uniq).to eq(['Gagosian Gallery'])
      end
    end
  end
end
