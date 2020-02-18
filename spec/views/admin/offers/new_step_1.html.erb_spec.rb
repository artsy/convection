# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/offers/new_step_1.html.erb', type: :feature do
  context 'with an offer' do
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
    let(:submission) { Fabricate(:submission, state: Submission::APPROVED) }
    let(:partner_submission) do
      Fabricate(:partner_submission, partner: partner, submission: submission)
    end

    before do
      allow_any_instance_of(Admin::OffersController).to receive(
        :require_artsy_authentication
      )
    end

    describe 'auction consignment offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{
                     submission.id
                   }&partner_id=#{partner.id}&offer_type=auction+consignment"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content(
          "Auction consignment offer for Submission ##{
            submission.id
          } by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Deadline to consign')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Low estimate')
        expect(page).to have_content('High estimate')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale name')
        expect(page).to have_content('Sale date')
        expect(page).to_not have_content('Price')
      end

      it 'allows you to create an offer' do
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)

        allow(Convection.config).to receive(:gravity_xapp_token).and_return(
          'xapp_token'
        )
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
            'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
          }
        )
        fill_in('offer_commission_percent_whole', with: '10')
        fill_in('offer_low_estimate_dollars', with: '100')
        fill_in('offer_high_estimate_dollars', with: '300')
        fill_in('offer_photography_info', with: '$50')
        fill_in('offer_shipping_info', with: '$70')
        fill_in('offer_insurance_info', with: '$10')
        fill_in('offer_deadline_to_consign', with: 'next week')
        fill_in('offer_other_fees_info', with: '$5')

        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('State draft')
        expect(page).to have_content('Commission % 10.0')
        expect(page).to have_content('Low estimate $100')
        expect(page).to have_content('High estimate $300')
        expect(page).to have_content('Shipping $70')
        expect(page).to have_content('Photography $50')
        expect(page).to have_content('Insurance $10')
        expect(page).to have_content('Deadline to consign next week')
        expect(page).to have_content('Other fees $5')
      end
    end

    describe 'purchase offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{
                     submission.id
                   }&partner_id=#{partner.id}&offer_type=purchase"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content(
          "Purchase offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Deadline to consign')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price')
        expect(page).to_not have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end

      it 'allows you to create an offer' do
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)

        allow(Convection.config).to receive(:gravity_xapp_token).and_return(
          'xapp_token'
        )
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
            'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
          }
        )
        fill_in('offer_price_dollars', with: '700')
        fill_in('offer_photography_info', with: '$50')
        fill_in('offer_shipping_info', with: '$70')
        fill_in('offer_insurance_info', with: '$10')
        fill_in('offer_deadline_to_consign', with: 'next week')
        fill_in('offer_other_fees_info', with: '$5')

        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('State draft')
        expect(page).to have_content('Price $700')
        expect(page).to have_content('Shipping $70')
        expect(page).to have_content('Photography $50')
        expect(page).to have_content('Insurance $10')
        expect(page).to have_content('Deadline to consign next week')
        expect(page).to have_content('Other fees $5')
      end
    end

    describe 'retail offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{
                     submission.id
                   }&partner_id=#{partner.id}&offer_type=retail"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content(
          "Retail offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Deadline to consign')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Retail price')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end

      it 'allows you to create an offer' do
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)

        allow(Convection.config).to receive(:gravity_xapp_token).and_return(
          'xapp_token'
        )
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
            'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
          }
        )

        fill_in('offer_price_dollars', with: '700')
        fill_in('offer_commission_percent_whole', with: '12.5')
        fill_in('offer_photography_info', with: '$50')
        fill_in('offer_shipping_info', with: '$70')
        fill_in('offer_insurance_info', with: '$10')
        fill_in('offer_deadline_to_consign', with: 'next week')
        fill_in('offer_other_fees_info', with: '$5')

        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('State draft')
        expect(page).to have_content('Commission % 12.5')
        expect(page).to have_content('Retail price $700')
        expect(page).to have_content('Shipping $70')
        expect(page).to have_content('Photography $50')
        expect(page).to have_content('Insurance $10')
        expect(page).to have_content('Deadline to consign next week')
        expect(page).to have_content('Other fees $5')
      end
    end

    describe 'net price offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{
                     submission.id
                   }&partner_id=#{partner.id}&offer_type=net+price"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content(
          "Net price offer for Submission ##{submission.id} by Gagosian Gallery"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography')
        expect(page).to have_content('Shipping')
        expect(page).to have_content('Insurance')
        expect(page).to have_content('Deadline to consign')
        expect(page).to have_content('Other fees')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Net sale price ')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
        expect(page).to_not have_content('Commission %')
      end

      it 'allows you to create an offer' do
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)

        allow(Convection.config).to receive(:gravity_xapp_token).and_return(
          'xapp_token'
        )
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
            'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
          }
        )

        fill_in('offer_price_dollars', with: '700')
        fill_in('offer_photography_info', with: '$50')
        fill_in('offer_shipping_info', with: '$70')
        fill_in('offer_insurance_info', with: '$10')
        fill_in('offer_deadline_to_consign', with: 'next week')
        fill_in('offer_other_fees_info', with: '$5')

        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('State draft')
        expect(page).to have_content('Price $700')
        expect(page).to have_content('Shipping $70')
        expect(page).to have_content('Photography $50')
        expect(page).to have_content('Insurance $10')
        expect(page).to have_content('Deadline to consign next week')
        expect(page).to have_content('Other fees $5')
      end
    end
  end
end
