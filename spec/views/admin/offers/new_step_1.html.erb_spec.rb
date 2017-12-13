require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/offers/new_step_1.html.erb', type: :feature do
  context 'with an offer' do
    let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
    let(:submission) { Fabricate(:submission) }
    let(:partner_submission) { Fabricate(:partner_submission, partner: partner, submission: submission) }

    before do
      allow_any_instance_of(Admin::OffersController).to receive(:require_artsy_authentication)
    end

    describe 'auction consignment offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{submission.id}&partner_id=#{partner.id}&offer_type=auction+consignment"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content("Auction consignment offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Low estimate cents')
        expect(page).to have_content('High estimate cents')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale name')
        expect(page).to have_content('Sale date')
        expect(page).to_not have_content('Price cents')
      end

      it 'allows you to create an offer' do
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
        fill_in('offer_commission_percent', with: '10')
        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('(draft)')
        expect(page).to have_content('Commission % 10.0')
      end
    end

    describe 'purchase offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{submission.id}&partner_id=#{partner.id}&offer_type=purchase"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content("Purchase offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price cents')
        expect(page).to have_content('Commission %')
        expect(page).to_not have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end

      it 'allows you to create an offer' do
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
        fill_in('offer_commission_percent', with: '10')
        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('(draft)')
        expect(page).to have_content('Commission % 10.0')
      end
    end

    describe 'consignment period offer' do
      before do
        page.visit "/admin/offers/new_step_1?submission_id=#{submission.id}&partner_id=#{partner.id}&offer_type=consignment+period"
      end

      it 'displays the page title and content' do
        expect(page).to have_content('New Offer')
        expect(page).to have_content("Consignment period offer for Submission ##{submission.id} by Gagosian Gallery")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('Currency')
        expect(page).to have_content('Photography cents')
        expect(page).to have_content('Shipping cents')
        expect(page).to have_content('Insurance cents')
        expect(page).to have_content('Insurance %')
        expect(page).to have_content('Other fees cents')
        expect(page).to have_content('Other fees %')
        expect(page).to have_content('Notes')
      end

      it 'displays all of the specific fields' do
        expect(page).to have_content('Price cents')
        expect(page).to have_content('Commission %')
        expect(page).to have_content('Sale period start')
        expect(page).to have_content('Sale period end')
        expect(page).to_not have_content('Sale name')
      end

      it 'allows you to create an offer' do
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
        fill_in('offer_commission_percent', with: '10')
        click_button('Create')
        expect(page).to have_content('Offer #')
        expect(page).to have_content('(draft)')
        expect(page).to have_content('Commission % 10.0')
      end
    end
  end
end
