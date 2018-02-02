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
      expect(page).to have_selector('.list-group-item', count: 1)
    end

    it 'shows the consignment states that can be selected' do
      within(:css, '#consignment-filter-form') do
        expect(page).to have_content('all')
        expect(page).to have_content('unconfirmed')
        expect(page).to have_content('signed')
        expect(page).to have_content('sold')
        expect(page).to have_content('bought in')
        expect(page).to have_content('closed')
      end
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
        expect(page).to have_selector('.list-group-item', count: 4)
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
        stub_gravity_user(id: consignment.submission.user.gravity_user_id)
        stub_gravity_user_detail(id: consignment.submission.user.gravity_user_id)
        stub_gravity_artist(id: consignment.submission.artist_id)
        page.visit admin_consignments_path

        find(".list-item--consignment[data-id='#{consignment.id}']").click
        expect(page).to have_content("Consignment ##{consignment.reference_id}")
      end

      it 'lets you click a filter option', js: true do
        select('signed', from: 'state')
        expect(page).to have_selector('.list-group-item', count: 1)
        expect(current_url).to include '&state=signed'
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

      it 'lets you click into a filter option', js: true do
        within(:css, '#consignment-filter-form') do
          select('signed', from: 'state')
        end
        expect(current_url).to include '&state=signed'
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'filters by changing the url' do
        page.visit('/admin/consignments?state=bought+in')
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 1)
      end

      it 'allows you to search by partner name', js: true do
        fill_in('term', with: 'gallery')
        page.execute_script("$('#consignment-filter-form').submit()")
        expect(current_url).to include '&term=gallery'
        partner_names = page.all('.list-group-item-info--partner-name').map(&:text)
        expect(partner_names.count).to eq 3
        expect(partner_names.uniq).to eq(['Gagosian Gallery'])
      end

      it 'allows you to search by partner name and state', js: true do
        fill_in('term', with: 'herit')
        page.execute_script("$('#consignment-filter-form').submit()")
        expect(current_url).to include '&term=herit'
        partner_names = page.all('.list-group-item-info--partner-name').map(&:text)
        expect(partner_names.count).to eq 3
        expect(partner_names.uniq).to eq(['Heritage Auctions'])
        select('signed', from: 'state')
        expect(current_url).to include '&state=signed&term=herit'
        expect(page).to have_selector('.list-group-item', count: 2)
      end
    end
  end
end
