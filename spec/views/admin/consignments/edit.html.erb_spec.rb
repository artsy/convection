require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/consignments/edit.html.erb', type: :feature do
  context 'with a consignment' do
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
      allow_any_instance_of(Admin::ConsignmentsController).to receive(:require_artsy_authentication)

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

      page.visit edit_admin_consignment_path(partner_submission)
    end

    describe 'editing' do
      it 'displays the page title and content' do
        expect(page).to have_content("Consignment ##{partner_submission.reference_id}")
      end

      it 'displays all of the shared fields' do
        expect(page).to have_content('State')
        expect(page).to have_content('Currency')
        expect(page).to have_content('Price cents')
        expect(page).to have_content('Date')
        expect(page).to have_content('Name')
        expect(page).to have_content('Location')
        expect(page).to have_content('Lot number')
        expect(page).to have_content('Partner commission %')
        expect(page).to have_content('Artsy commission %')
        expect(page).to have_content('Notes')

        expect(find_field('partner_submission_sale_name').value).to eq('July Prints & Multiples')
      end

      it 'allows you to edit a consignment' do
        fill_in('partner_submission_sale_name', with: 'August Sale')
        click_button('Save')
        expect(page.current_path).to eq admin_consignment_path(partner_submission)
        expect(page).to have_content('Name August Sale')
      end
    end
  end
end
