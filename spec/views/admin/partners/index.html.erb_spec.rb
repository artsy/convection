# frozen_string_literal: true

require 'rails_helper'

describe 'admin/partners/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      Fabricate(:partner, name: 'Gagosian Gallery')
      Fabricate(:partner, name: 'Alan Cristea Gallery')
      Fabricate(:partner, name: 'Rosier Gallery')
      Fabricate(:partner, name: 'Auction House')
      page.visit '/admin/partners'
    end

    it 'displays all of the partners when no term is set' do
      partner_names = page.all('.list-item--partner--name').map(&:text)
      expect(partner_names).to eq(
        [
          'Alan Cristea Gallery',
          'Auction House',
          'Gagosian Gallery',
          'Rosier Gallery'
        ]
      )
    end

    it 'allows for searching by prefix' do
      fill_in('term', with: 'gag')
      click_button('Search')
      expect(page).to have_content('Gagosian Gallery')
      expect(page).to have_selector('.list-group-item', count: 1)
    end

    it 'allows for searching by a common term' do
      fill_in('term', with: 'gallery')
      click_button('Search')
      partner_names = page.all('.list-item--partner--name').map(&:text)
      expect(partner_names).to eq(
        ['Alan Cristea Gallery', 'Gagosian Gallery', 'Rosier Gallery']
      )
    end
  end
end
