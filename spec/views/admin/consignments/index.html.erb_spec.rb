# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/consignments/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )

      stub_gravity_root
      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      @artists = [
        { id: 'artist1', name: 'Andy Warhol' },
        { id: 'artist2', name: 'Kara Walker' }
      ]

      gravql_artists_response = { data: { artists: @artists } }
      stub_gravity_artists
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      page.visit admin_consignments_path
    end

    it 'displays the page title' do
      expect(page).to have_content('Consignments')
      expect(page).to have_selector('.list-group-item', count: 1)
    end

    it 'shows the consignment states that can be selected' do
      within(:css, '#consignment-filter-form') do
        expect(page).to have_content('all')
        expect(page).to have_content('sold')
        expect(page).to have_content('bought in')
        expect(page).to have_content('canceled')
      end
    end

    context 'with some consignments' do
      before do
        3.times { Fabricate(:consignment, state: 'open') }
        page.visit admin_consignments_path
      end

      it 'displays all of the consignments' do
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 4)
      end

      it 'lets you click a consignment' do
        consignment = PartnerSubmission.consigned.first
        stub_gravity_root
        stub_gravity_user(id: consignment.submission.user.gravity_user_id)
        stub_gravity_user_detail(
          id: consignment.submission.user.gravity_user_id
        )
        stub_gravity_artist(id: consignment.submission.artist_id)
        page.visit admin_consignments_path

        find(".list-item--consignment[data-id='#{consignment.id}']").click
        expect(page).to have_content("Consignment ##{consignment.reference_id}")
      end

      it 'lets you click a filter option', js: true do
        select('bought in', from: 'state')
        expect(page).to have_selector('.list-group-item', count: 1)
        expect(current_url).to include 'state=bought+in'
      end
    end

    context 'with a variety of consignments' do
      before do
        @partner1 = Fabricate(:partner, name: 'Gagosian Gallery')
        @partner2 = Fabricate(:partner, name: 'Heritage Auctions')
        3.times { Fabricate(:consignment, state: 'open', partner: @partner1) }
        @consignment1 =
          Fabricate(:consignment, state: 'bought in', partner: @partner2)
        Fabricate(:consignment, state: 'sold', partner: @partner2)
        Fabricate(:consignment, state: 'canceled', partner: @partner2)
        page.visit admin_consignments_path

        stub_gravity_user(id: @consignment1.submission.user.gravity_user_id)
        stub_gravity_user_detail(
          id: @consignment1.submission.user.gravity_user_id
        )
      end

      it 'lets you click into a filter option', js: true do
        within(:css, '#consignment-filter-form') do
          select('bought in', from: 'state')
        end
        expect(current_url).to include 'state=bought+in'
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'filters by changing the url' do
        page.visit('/admin/consignments?state=bought+in')
        expect(page).to have_content('Consignments')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'allows you to search by partner name', js: true do
        page.all(:fillable_field, 'term').last.set('gallery')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Gagosian Gallery')
        click_link("partner-#{@partner1.id}")
        expect(current_url).to include "partner=#{@partner1.id}"
        expect(page).to have_selector("input[value='#{@partner1.name}']")
        partner_names =
          page.all('.list-group-item-info--partner-name').map(&:text)
        expect(partner_names.count).to eq 3
        expect(partner_names.uniq).to eq(['Gagosian Gallery'])
      end

      it 'allows you to navigate to a specific consignment', js: true do
        page.all(:fillable_field, 'term').last.set(@consignment1.reference_id)
        expect(page).to have_selector('.ui-autocomplete')
        click_link("consignment-#{@consignment1.id}")
        expect(current_path).to eq admin_consignment_path(@consignment1)
      end

      it 'allows you to search by partner name and state', js: true do
        select('bought in', from: 'state')
        page.all(:fillable_field, 'term').last.set('herit')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Heritage Auctions')
        click_link("partner-#{@partner2.id}")
        partner_names =
          page.all('.list-group-item-info--partner-name').map(&:text)
        expect(partner_names.count).to eq 1
        expect(partner_names.first).to eq('Heritage Auctions')
        expect(current_url).to include "state=bought+in&partner=#{@partner2.id}"
        expect(page).to have_selector("input[value='#{@partner2.name}']")
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'allows you to search by artist name', js: true do
        artist = @artists.first
        @consignment1.submission.update!(artist_id: artist[:id])

        stub_gravity_artists(override_body: [artist])

        page.all(:fillable_field, 'term').last.set(artist[:name])
        expect(page).to have_selector('.ui-autocomplete')
        click_link("artist-#{artist[:id]}")
        expect(current_url).to include "&artist=#{artist[:id]}"
        expect(page).to have_content(artist[:name])
        expect(page).to have_selector('.list-group-item-info--artist', count: 1)
      end

      it 'allows you to search by artist name and state', js: true do
        artist = @artists.first
        @consignment1.submission.update!(artist_id: artist[:id])

        stub_gravity_artists(override_body: [artist])

        page.all(:fillable_field, 'term').last.set(artist[:name])
        expect(page).to have_selector('.ui-autocomplete')
        click_link("artist-#{artist[:id]}")
        select('bought in', from: 'state')
        expect(current_url).to include(
          "artist=#{artist[:id]}",
          'state=bought+in'
        )
        expect(page).to have_content(artist[:name])
        expect(page).to have_selector('.list-group-item-info--artist', count: 1)
        select('sold', from: 'state')
        expect(page).to have_selector('.list-group-item-info--artist', count: 0)
      end

      it 'allows you to search by partner name, filter by state, and sort by estimate',
         js: true do
        select('bought in', from: 'state')
        page.all(:fillable_field, 'term').last.set('herit')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Heritage Auctions')
        click_link("partner-#{@partner2.id}")
        expect(current_url).to include "state=bought+in&partner=#{@partner2.id}"
        expect(page).to have_selector("input[value='#{@partner2.name}']")
        click_link('Estimate')
        expect(current_url).to include(
          "partner=#{@partner2.id}",
          'state=bought+in',
          'sort=offers.high_estimate_cents',
          'direction=desc'
        )
        expect(page).to have_selector("input[value='#{@partner2.name}']")
      end
    end
  end
end
