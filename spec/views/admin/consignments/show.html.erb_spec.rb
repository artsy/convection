require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/consignments/show.html.erb', type: :feature do
  context 'always' do
    let(:submission) { Fabricate(:submission, category: 'Painting', state: 'approved') }
    let(:partner) { Fabricate(:partner) }
    let(:partner_submission) { Fabricate(:partner_submission, submission: submission, partner: partner) }
    let(:offer) do
      Fabricate(:offer,
        partner_submission: partner_submission,
        offer_type: 'purchase',
        state: 'accepted',
        price_cents: 12_000)
    end

    before do
      partner_submission.update_attributes!(
        state: 'unconfirmed',
        accepted_offer_id: offer.id,
        sale_name: 'July Prints & Multiples',
        sale_location: 'London'
      )
      submission.update_attributes!(consigned_partner_submission_id: partner_submission.id)
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)

      stub_jwt_header('userid')
      stub_gravity_root
      stub_gravity_user(name: 'Lucille Bluth')
      stub_gravity_artist(id: submission.artist_id)
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
      page.visit admin_consignment_path(partner_submission)
    end

    describe 'performs basic functions' do
      it 'displays the page title and content' do
        expect(page).to have_content("Consignment ##{partner_submission.reference_id} (unconfirmed)")
        expect(page).to have_content('Name July Prints & Multiples')
        expect(page).to have_content('Location London')
      end

      it 'shows information about the offer and lets you navigate' do
        expect(page).to have_selector('.list-item--offer')
        within(:css, '.list-item--offer') do
          expect(page).to have_content 'accepted'
          expect(page).to have_content '12000'
        end
        find('.list-item--offer').click
        expect(page.current_path).to eq(admin_offer_path(offer))
      end

      it 'shows information about the submission and lets you navigate' do
        expect(page).to have_selector('.list-item--offer')
        within(:css, '.list-item--submission') do
          expect(page).to have_content 'approved'
          expect(page).to have_content 'Painting'
        end
        find('.list-item--submission').click
        expect(page.current_path).to eq(admin_submission_path(submission))
      end

      it 'lets you enter the edit view' do
        expect(page).to have_content 'Edit'
        click_link('Edit')
        expect(page.current_path).to eq(edit_admin_consignment_path(partner_submission))
      end

      it 'lets you change the partner_paid_at field' do
        expect(page).to have_selector('.partner-paid .toggle[data-state="no"]')
        page.find('.partner-paid .toggle').click
        expect(page).to_not have_selector('.partner-paid .toggle[data-state="no"]')
        expect(page).to have_selector('.partner-paid .toggle[data-state="yes"]')
      end

      it 'lets you change the partner_invoiced_at field' do
        expect(page).to have_selector('.partner-invoiced .toggle[data-state="no"]')
        page.find('.partner-invoiced .toggle').click
        expect(page).to_not have_selector('.partner-invoiced .toggle[data-state="no"]')
        expect(page).to have_selector('.partner-invoiced .toggle[data-state="yes"]')
      end
    end
  end
end
