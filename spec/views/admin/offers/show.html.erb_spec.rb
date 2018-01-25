require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/offers/show.html.erb', type: :feature do
  context 'always' do
    let(:submission) { Fabricate(:submission) }
    let(:partner) { Fabricate(:partner) }
    let(:partner_submission) { Fabricate(:partner_submission, submission: submission, partner: partner) }
    let(:offer) { Fabricate(:offer, partner_submission: partner_submission, offer_type: 'purchase', state: 'draft') }

    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
      stub_jwt_header('userid')

      stub_gravity_root
      stub_gravity_user(name: 'Lucille Bluth')
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
      page.visit "/admin/offers/#{offer.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Offer ##{offer.reference_id}")
      expect(page).to have_content('Offer type purchase')
    end

    it 'lets you delete the offer' do
      stub_gravity_artist(id: submission.artist_id)
      expect(page).to have_selector('#offer-delete-button')
      click_link('offer-delete-button')
      expect(page.current_path).to eq("/admin/submissions/#{submission.id}")
      expect(page).to have_content('Offer deleted')
    end

    it 'does not display the delete button if not in draft state' do
      offer.update_attributes!(state: 'sent')
      page.visit "/admin/offers/#{offer.id}"
      expect(page).to_not have_selector('#offer-delete-button')
    end

    describe 'save & send' do
      it 'shows the save & send button when offer is in draft state' do
        offer.update_attributes!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Save & Send')
        expect(page).to have_selector('.offer-draft-actions')
      end

      it 'does not show the save & send button after the offer has been sent' do
        offer.update_attributes!(state: 'sent')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to_not have_content('Save & Send')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to save the offer' do
        stub_gravity_artist(id: submission.artist_id)
        offer.update_attributes!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        click_link('Save & Send')
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_content('Save & Send')
      end
    end

    describe 'offer lapsed' do
      before do
        offer.update_attributes!(state: 'sent')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the offer lapsed button' do
        expect(page).to_not have_content('Save & Send')
        expect(page).to have_content('Offer Lapsed')
      end

      it 'allows you to mark the offer as lapsed' do
        click_link('Offer Lapsed')
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content('State lapsed')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to_not have_selector('.offer-actions')
      end
    end

    describe 'offer introduced' do
      before do
        offer.update_attributes!(state: 'sent')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the introduce offer button' do
        expect(page).to_not have_content('Save & Send')
        expect(page).to have_content('Introduce')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to mark the offer as introduced' do
        expect(page).to have_selector('.offer-introduce-button')
        click_link('Introduce')
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_selector('.offer-introduce-button')
        expect(page).to have_content('Introduced by Lucille Bluth')
      end
    end

    describe 'offer consigned' do
      before do
        offer.update_attributes!(state: 'introduced')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the complete consignment button' do
        expect(page).to have_content('Complete Consignment')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to mark the offer as consigned', js: true do
        expect(find('input#terms_signed')).to_not be_checked
        expect(page).to have_selector('.offer-consign-button.disabled-button')
        find('input#terms_signed').click
        expect(page).to_not have_selector('.offer-consign-button.disabled-button')
        find('.offer-consign-button').click
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_content('Complete Consignment')
        expect(page).to have_selector('.list-item--consignment')
        find('.list-item--consignment').click
        expect(page.current_path).to include('/admin/consignment')
      end
    end

    describe 'offer locked' do
      before do
        offer.update_attributes!(state: 'locked')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows no actions' do
        expect(page).to have_content('State locked')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to_not have_selector('.offer-actions')
      end
    end

    describe 'offer rejected' do
      before do
        offer.update_attributes!(state: 'sent')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the reject offer button' do
        expect(page).to_not have_content('Save & Send')
        expect(page).to have_content('Reject Offer')
      end

      it 'allows you to mark the offer as rejected with a note' do
        click_link('Reject Offer')
        choose('offer_rejection_reason_low_estimate')
        click_button('Save and Send')
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_content('Reject Offer')
        expect(page).to have_content('Rejected by Lucille Bluth. Low estimate')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to_not have_selector('.offer-actions')
      end

      it 'allows you to add notes to the rejection' do
        click_link('Reject Offer')
        choose('offer_rejection_reason_other')
        fill_in('offer_rejection_note', with: 'The user has issues with who the partner is.')
        click_button('Save and Send')
        expect(page).to have_content('Rejected by Lucille Bluth. Other: The user has issues with who the partner is.')
      end
    end
  end
end
