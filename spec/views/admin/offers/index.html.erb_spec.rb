# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/offers/index.html.erb', type: :feature do
  context 'always' do
    before do
      stub_gravity_root

      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      gravql_artists_response = {
        data: { artists: [{ id: 'artist1', name: 'Andy Warhol' }] }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json).with(
        headers: {
          'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
        }
      )

      page.visit admin_offers_path
    end

    it 'displays the page title' do
      expect(page).to have_content('Offers')
      expect(page).to have_selector('.list-group-item', count: 1)
    end

    it 'shows the offer states that can be selected' do
      within(:css, '#offer-filter-form') do
        expect(page).to have_content('all')
        expect(page).to have_content('draft')
        expect(page).to have_content('sent')
        expect(page).to have_content('accepted')
        expect(page).to have_content('rejected')
        expect(page).to have_content('lapsed')
      end
    end

    context 'offer state' do
      let(:offer) { Fabricate(:offer) }

      it 'displays the correct state when the offer has a "reject" response' do
        Fabricate(
          :offer_response,
          offer: offer, intended_state: Offer::REJECTED
        )
        page.visit admin_offers_path
        expect(page).to have_content('Response: Reject')
      end

      it 'displays the correct state when the offer has an "accept" response' do
        Fabricate(
          :offer_response,
          offer: offer, intended_state: Offer::ACCEPTED
        )
        page.visit admin_offers_path
        expect(page).to have_content('Response: Accept')
      end

      it 'displays the correct state when the offer has an "interested" response' do
        Fabricate(:offer_response, offer: offer, intended_state: Offer::REVIEW)
        page.visit admin_offers_path
        expect(page).to have_content('Response: Interested')
      end

      it 'displays the correct state when the offer is sent' do
        offer.update!(state: Offer::SENT)
        page.visit admin_offers_path
        within(:css, 'a.list-group-item') do
          expect(page).to have_content('sent')
        end
      end

      it 'displays the correct state when the offer is accepted' do
        offer.update!(state: Offer::ACCEPTED)
        page.visit admin_offers_path
        within(:css, 'a.list-group-item') do
          expect(page).to have_content('accepted')
        end
      end
    end

    context 'with some offers' do
      before do
        3.times { Fabricate(:offer, state: 'sent') }
        page.visit admin_offers_path
      end

      it 'displays all of the offers' do
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 4)
      end

      it 'lets you click an offer' do
        offer = Offer.first
        stub_gravity_root
        stub_gravity_user(id: offer.submission.user.gravity_user_id)
        stub_gravity_user_detail(id: offer.submission.user.gravity_user_id)
        stub_gravity_artist(id: offer.submission.artist_id)

        find(".list-item--offer[data-id='#{offer.id}']").click
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content('Offer Lapsed')
      end

      it 'lets you click a filter option', js: true do
        select('sent', from: 'state')
        expect(current_url).to include '&state=sent'
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 4)
        expect(current_path).to eq admin_offers_path
      end

      it 'displays a lock symbol if the offer is locked' do
        ps =
          Fabricate(
            :partner_submission,
            submission: Fabricate(:submission, state: Submission::APPROVED)
          )
        accepted_offer = Fabricate(:offer, partner_submission: ps)
        Fabricate(:offer, partner_submission: ps)
        OfferService.consign!(accepted_offer)
        page.visit admin_offers_path
        expect(page).to have_selector('.locked', count: 1)
      end
    end

    context 'with a variety of offers' do
      before do
        @partner1 = Fabricate(:partner, name: 'Gagosian')
        @partner2 = Fabricate(:partner, name: 'Heritage Auctions')
        3.times do
          Fabricate(
            :offer,
            state: 'sent',
            partner_submission:
              Fabricate(:partner_submission, partner: @partner1)
          )
        end
        @offer1 =
          Fabricate(
            :offer,
            state: 'accepted',
            partner_submission:
              Fabricate(:partner_submission, partner: @partner2)
          )
        Fabricate(
          :offer,
          state: 'rejected',
          partner_submission: Fabricate(:partner_submission, partner: @partner2)
        )
        Fabricate(
          :offer,
          state: 'draft',
          partner_submission: Fabricate(:partner_submission, partner: @partner1)
        )

        stub_gravity_user(id: @offer1.submission.user.gravity_user_id)
        stub_gravity_user_detail(id: @offer1.submission.user.gravity_user_id)

        page.visit admin_offers_path
      end

      it 'lets you click into a filter option', js: true do
        select('accepted', from: 'state')
        expect(current_url).to include '&state=accepted'
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'filters by changing the url' do
        page.visit('/admin/offers?state=rejected')
        expect(page).to have_content('Offers')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'lets you search by partner name', js: true do
        fill_in('term', with: 'Gag')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Gagosian')
        click_link("partner-#{@partner1.id}")
        expect(current_url).to include "&partner=#{@partner1.id}"
        expect(page).to have_selector('.list-group-item', count: 5)
        expect(page).to have_content('sent', count: 5) # 3 items + "sent" and "sent with response" filters
        expect(page).to have_content('draft', count: 2)
      end

      it 'allows you to navigate to a specific offer', js: true do
        fill_in('term', with: @offer1.reference_id)
        expect(page).to have_selector('.ui-autocomplete')
        click_link("offer-#{@offer1.id}")
        expect(current_path).to eq admin_offer_path(@offer1)
      end

      it 'lets you search by state and partner name', js: true do
        select('sent', from: 'state')
        fill_in('term', with: 'Gag')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Gagosian')
        click_link("partner-#{@partner1.id}")
        expect(current_url).to include "state=sent&partner=#{@partner1.id}"
        expect(page).to have_selector('.list-group-item', count: 4)
        expect(page).to have_content('sent', count: 5) # 3 items + "sent" and "sent with response" filters
        expect(page).to have_content('draft', count: 1)
      end

      it 'allows you to search by partner name, filter by state, and sort by price_cents',
         js: true do
        select('sent', from: 'state')
        fill_in('term', with: 'Gag')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('Partner   Gagosian')
        click_link("partner-#{@partner1.id}")
        expect(current_url).to include "state=sent&partner=#{@partner1.id}"
        click_link('Price')
        expect(current_url).to include(
          "partner=#{@partner1.id}",
          'state=sent',
          'sort=price_cents',
          'direction=desc'
        )
      end
    end
  end
end
