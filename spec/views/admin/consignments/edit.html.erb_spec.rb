# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/consignments/edit.html.erb', type: :feature do
  context 'with a consignment' do
    let(:submission) do
      Fabricate(:submission, category: 'Painting', state: 'approved')
    end
    let(:partner) { Fabricate(:partner) }
    let(:partner_submission) do
      Fabricate(:partner_submission, submission: submission, partner: partner)
    end
    let(:offer) do
      Fabricate(
        :offer,
        partner_submission: partner_submission,
        offer_type: 'purchase',
        state: 'accepted',
        price_cents: 12_000
      )
    end

    before do
      partner_submission.update!(
        state: 'open',
        accepted_offer_id: offer.id,
        sale_name: 'July Prints & Multiples',
        sale_location: 'London'
      )
      submission.update!(consigned_partner_submission_id: partner_submission.id)
      allow_any_instance_of(Admin::ConsignmentsController).to receive(
        :require_artsy_authentication
      )

      stub_jwt_header('userid')
      stub_gravity_root
      stub_gravity_user(name: 'Lucille Bluth')
      stub_gravity_artist(id: submission.artist_id)
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
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )

      page.visit edit_admin_consignment_path(partner_submission)
    end

    describe 'editing' do
      it 'displays the page title and content' do
        expect(page).to have_content(
          "Consignment ##{partner_submission.reference_id}"
        )
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('State')
        expect(page).to have_content('Currency')
        expect(page).to have_content('Price')
        expect(page).to have_content('Date')
        expect(page).to have_content('Name')
        expect(page).to have_content('Location')
        expect(page).to have_content('Lot number')
        expect(page).to have_content('Partner commission %')
        expect(page).to have_content('Artsy commission %')
        expect(page).to have_content('Notes')

        expect(find_field('partner_submission_sale_name').value).to eq(
          'July Prints & Multiples'
        )
      end

      it 'allows you to edit a consignment' do
        fill_in('partner_submission_sale_name', with: 'August Sale')
        fill_in('partner_submission_sale_price_dollars', with: '700')
        fill_in(
          'partner_submission_partner_commission_percent_whole',
          with: '10'
        )
        fill_in(
          'partner_submission_artsy_commission_percent_whole',
          with: '8.8'
        )

        click_button('Save')
        expect(page.current_path).to eq admin_consignment_path(
             partner_submission
           )
        expect(page).to have_content('Name August Sale')
        expect(page).to have_content('Price $700')
        expect(page).to have_content(
          'Partner Commission (commission charged to seller) % 10.0'
        )
        expect(page).to have_content(
          'Artsy Commission (commission charged to partner) % 8.8'
        )
      end

      context 'when the consignment has a partner invoice date' do
        before do
          partner_submission.update!(partner_invoiced_at: Time.zone.now)
          page.visit edit_admin_consignment_path(partner_submission)
        end

        it 'allows you to edit the invoice number' do
          fill_in('partner_submission_invoice_number', with: '424242')

          click_button('Save')
          expect(page.current_path).to eq admin_consignment_path(
               partner_submission
             )
          expect(page).to have_content('Invoice number 424242')
        end
      end

      it 'shows the canceled reason box when canceled is selected', js: true do
        select('canceled', from: 'partner_submission_state')
        expect(page).to have_content 'Canceled Reason'
        fill_in(
          'partner_submission_canceled_reason',
          with: 'do not want this piece.'
        )
        click_button('Save')
        expect(page.current_path).to eq admin_consignment_path(
             partner_submission
           )
        expect(page).to have_content('State canceled')
        expect(page).to have_content('Canceled Reason do not want this piece.')
      end
    end
  end
end
