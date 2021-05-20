# frozen_string_literal: true

require 'rails_helper'

describe 'admin/dashboard/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      allow(ArtsyAdminAuth).to receive(
        :decode_user
      ).and_return('me')

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )

      page.visit '/'
    end

    it 'displays the section titles' do
      expect(page).to have_content('Unreviewed Submissions 0')
      expect(page).to have_content('Unassigned Submissions : 0')
      expect(page).to have_content('My Submissions : 0')
      expect(page).to have_content('Approved 0')
      expect(page).to have_content('Approved without CMS : 0')
      expect(page).to have_content('Published to CMS : 0')
      expect(page).to have_content('Offers 0')
      expect(page).to have_content('Sent : 0')
      expect(page).to have_content('Introduced : 0')
      expect(page).to have_content('Upcoming Consignments 0')
      expect(page).to have_content('Sold Consignments 0')
      expect(page).to have_content('Auction House : 0').twice
      expect(page).to have_content('Artsy Curated Auctions : 0').twice
    end

    it 'lets you click and go to filtered submissions page' do
      expect(page).to have_selector(".unreviewed-submissions .unassigned-submissions a[href='#{admin_submissions_path(state: :submitted, assigned_to: '')}']")
      expect(page).to have_selector(".unreviewed-submissions .my-submissions a[href='#{admin_submissions_path(state: :submitted, assigned_to: 'me')}']")

      expect(page).to have_selector(".approved-submissions .approved-without-cms a[href='#{admin_submissions_path(state: :approved)}']")
      expect(page).to have_selector(".approved-submissions .published-to-cms a[href='#{admin_submissions_path(state: :published)}']")
    end

    it 'lets you click and go to filtered offers page' do
      expect(page).to have_selector(".offers .sent a[href='#{admin_offers_path(state: :sent)}']")
      expect(page).to have_selector(".offers .introduced a[href='#{admin_offers_path(state: :review)}']")

      expect(page).to have_selector(".upcoming-consignments .auction-house a[href='#{admin_consignments_path(state: :open, term: '!Artsy')}']")
      expect(page).to have_selector(".upcoming-consignments .artsy-curated-auctions a[href='#{admin_consignments_path(state: :open, term: 'Artsy')}']")

      expect(page).to have_selector(".sold-consignments .auction-house a[href='#{admin_consignments_path(state: :sold, term: '!Artsy')}']")
      expect(page).to have_selector(".sold-consignments .artsy-curated-auctions a[href='#{admin_consignments_path(state: :sold, term: 'Artsy')}']")
    end

    it 'lets you click and go to filtered consignments page' do
      expect(page).to have_selector(".upcoming-consignments .auction-house a[href='#{admin_consignments_path(state: :open, term: '!Artsy')}']")
      expect(page).to have_selector(".upcoming-consignments .artsy-curated-auctions a[href='#{admin_consignments_path(state: :open, term: 'Artsy')}']")

      expect(page).to have_selector(".sold-consignments .auction-house a[href='#{admin_consignments_path(state: :sold, term: '!Artsy')}']")
      expect(page).to have_selector(".sold-consignments .artsy-curated-auctions a[href='#{admin_consignments_path(state: :sold, term: 'Artsy')}']")
    end

    context 'with just submissions' do
      before do
        Fabricate(:submission, state: 'draft', assigned_to: nil)
        Fabricate(:submission, state: 'approved', assigned_to: 'me')
        2.times { Fabricate(:submission, state: 'submitted', assigned_to: nil) }
        2.times { Fabricate(:submission, state: 'submitted', assigned_to: 'some_user') }
        Fabricate(:submission, state: 'submitted', assigned_to: 'me')
        page.visit '/'
      end
    end

    context 'with some offers and submissions and consignments' do
      before do
        2.times { Fabricate(:offer, state: 'sent') }
        Fabricate(:offer, state: 'review')
        Fabricate(:offer, state: 'draft')

        2.times { Fabricate(:submission, state: 'submitted', assigned_to: 'me') }
        Fabricate(:submission, state: 'submitted', assigned_to: nil)
        Fabricate(:submission, state: 'submitted', assigned_to: 'some_user')
        Fabricate(:submission, state: 'approved', assigned_to: 'me')
        2.times { Fabricate(:submission, state: 'published', assigned_to: nil) }
        Fabricate(:submission, state: 'draft', assigned_to: 'me')

        artsy = Fabricate(:partner, name: 'Artsy')
        artsy_curated = Fabricate(:partner, name: 'Artsy x Gagosian Gallery')
        non_artsy = Fabricate(:partner, name: 'Gagosian Gallery')

        Fabricate(:consignment, state: 'open', partner: artsy)
        Fabricate(:consignment, state: 'open', partner: non_artsy)

        2.times { Fabricate(:consignment, state: 'sold', partner: artsy_curated) }
        Fabricate(:consignment, state: 'sold', partner: non_artsy)
        page.visit '/'
      end

      it 'displays right counts for Unreviewed Submissions category' do
        expect(page).to have_content('Unreviewed Submissions 4')
        expect(page).to have_content('Unassigned Submissions : 1')
        expect(page).to have_content('My Submissions : 2')

        expect(page).to have_content('Approved 3')
        expect(page).to have_content('Approved without CMS : 1')
        expect(page).to have_content('Published to CMS : 2')

        expect(page).to have_content('Offers 9') # 5 from consignments
        expect(page).to have_content('Sent : 2')
        expect(page).to have_content('Introduced : 1')

        expect(page).to have_content('Upcoming Consignments 2')
        expect(page).to have_content('Auction House : 1')
        expect(page).to have_content('Artsy Curated Auctions : 1')

        expect(page).to have_content('Sold Consignments 3')
        expect(page).to have_content('Auction House : 1')
        expect(page).to have_content('Artsy Curated Auctions : 2')
      end
    end
  end
end
