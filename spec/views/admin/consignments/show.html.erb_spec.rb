# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/consignments/show.html.erb', type: :feature do
  context 'always' do
    let(:submission) do
      Fabricate(
        :submission,
        category: 'Painting',
        state: 'approved',
        user: Fabricate(:user, gravity_user_id: 'userid')
      )
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
      allow_any_instance_of(ApplicationController).to receive(
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
      page.visit admin_consignment_path(partner_submission)
    end

    describe 'performs basic functions' do
      it 'displays the page title and content' do
        expect(page).to have_content(
          "Consignment ##{partner_submission.reference_id}"
        )
        expect(page).to have_content('Name July Prints & Multiples')
        expect(page).to have_content('Location London')
        expect(page).to_not have_content('Canceled Reason')
      end

      context 'when the consignment has a partner invoice date' do
        before do
          partner_submission.update!(
            partner_invoiced_at: Time.zone.now,
            invoice_number: 424_242
          )
          page.visit admin_consignment_path(partner_submission)
        end

        it 'displays the invoice number' do
          expect(page).to have_content('Invoice number 424242')
        end
      end

      it 'shows information about the offer and lets you navigate' do
        expect(page).to have_selector('.list-item--offer')
        within(:css, '.list-item--offer') do
          expect(page).to have_content 'accepted'
        end
        find('.list-item--offer').click
        expect(page.current_path).to eq(admin_offer_path(offer))
      end

      it 'shows information about the submission and lets you navigate' do
        expect(page).to have_selector('.list-item--offer')
        within(:css, '.list-item--submission') do
          expect(page).to have_content 'approved'
          expect(page).to have_content submission.title
        end
        find('.list-item--submission').click
        expect(page.current_path).to eq(admin_submission_path(submission))
      end

      it 'shows a canceled reason if the consignment has been canceled' do
        partner_submission.update!(
          state: 'canceled',
          canceled_reason: 'done with this piece.'
        )
        page.visit admin_consignment_path(partner_submission)
        expect(page).to have_content 'Canceled Reason'
        expect(page).to have_content 'done with this piece.'
      end

      it 'lets you enter the edit view' do
        expect(page).to have_content 'Edit'
        click_link('Edit')
        expect(page.current_path).to eq(
          edit_admin_consignment_path(partner_submission)
        )
      end

      it 'lets you change the partner_paid_at field' do
        expect(page).to have_selector('.partner-paid .toggle[data-state="no"]')
        page.find('.partner-paid .toggle').click
        expect(page).to_not have_selector(
                              '.partner-paid .toggle[data-state="no"]'
                            )
        expect(page).to have_selector('.partner-paid .toggle[data-state="yes"]')
      end

      it 'lets you change the partner_invoiced_at field' do
        expect(page).to have_selector(
          '.partner-invoiced .toggle[data-state="no"]'
        )
        page.find('.partner-invoiced .toggle').click
        expect(page).to_not have_selector(
                              '.partner-invoiced .toggle[data-state="no"]'
                            )
        expect(page).to have_selector(
          '.partner-invoiced .toggle[data-state="yes"]'
        )
      end
    end
  end
end
