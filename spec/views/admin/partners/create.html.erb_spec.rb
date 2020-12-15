# frozen_string_literal: true

require 'rails_helper'

describe 'partners create', type: :feature do
  context 'always', js: true do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      Fabricate(:partner, name: 'Gagosian Gallery')
      Fabricate(:partner, name: 'Alan Cristea Gallery')
      Fabricate(:partner, name: 'Rosier Gallery')
      Fabricate(:partner, name: 'Auction House')

      gravql_match_partners_response = {
        data: { match_partners: [{ id: 'partner1', given_name: 'Storefront' }] }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_match_partners_response.to_json)

      page.visit '/admin/partners'
    end

    it 'allows you to create a partner' do
      expect(Partner.count).to eq 4
      click_link('Add Partner')
      expect(page).to have_selector(
        '#partner-selections-form #partner-search-submit.disabled-button'
      ) # button is disabled at first
      fill_in('gravity_partner', with: 'store')
      expect(page).to have_selector('.ui-menu-item a')
      page.execute_script(
        "$('.ui-menu-item:contains(\"Storefront\")').find('a').trigger('mouseenter').click()"
      )
      expect(page).to_not have_selector(
                            '#partner-selections-form #partner-search-submit.disabled-button'
                          )
      click_button('Create Partner')
      expect(page).to have_content('Partner successfully created.')
      expect(Partner.count).to eq 5
      expect(Partner.last.name).to eq 'Storefront'
    end

    it 'does not create a partner if the create partner button is not clicked' do
      expect(Partner.count).to eq 4
      click_link('Add Partner')
      expect(page).to have_selector(
        '#partner-selections-form #partner-search-submit.disabled-button'
      ) # button is disabled at first
      fill_in('gravity_partner', with: 'store')
      expect(page).to have_selector('.ui-menu-item a')
      page.execute_script(
        "$('.ui-menu-item:contains(\"Storefront\")').find('a').trigger('mouseenter').click()"
      )
      expect(page).to_not have_selector(
                            '#partner-selections-form #partner-search-submit.disabled-button'
                          )
      find('#create-partner-close').click
      expect(page).to_not have_content('Partner successfully created.')
      expect(Partner.count).to eq 4
    end
  end
end
