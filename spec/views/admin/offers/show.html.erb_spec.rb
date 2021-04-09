# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'
require 'support/gravql_helper'
require 'support/jwt_helper'

describe 'admin/offers/show.html.erb', type: :feature do
  context 'always' do
    let(:submission) { Fabricate(:submission, state: Submission::APPROVED) }
    let(:partner) { Fabricate(:partner) }
    let(:partner_submission) do
      Fabricate(:partner_submission, submission: submission, partner: partner)
    end
    let(:offer) do
      Fabricate(
        :offer,
        partner_submission: partner_submission,
        offer_type: 'purchase',
        state: 'draft',
        partner_info: 'Testing partner info'
      )
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      stub_jwt_header('userid')

      stub_gravity_root
      stub_gravity_user(name: 'Lucille Bluth')
      stub_gravity_user(id: submission.user.gravity_user_id)
      stub_gravity_user_detail(id: submission.user.gravity_user_id)

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )

      stub_gravql_artists(body: {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol', is_p1: true, target_supply: true },
            { id: 'artist2', name: 'Kara Walker', is_p1: true, target_supply: true }
          ]
        }
      })
      page.visit "/admin/offers/#{offer.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Offer ##{offer.reference_id}")
      expect(page).to have_content('Offer type purchase')
      expect(page).to have_content('Testing partner info')
    end

    it 'lets you delete the offer' do
      stub_gravity_artist(id: submission.artist_id)
      expect(page).to have_selector('#offer-delete-button')
      click_link('offer-delete-button')
      expect(page.current_path).to eq("/admin/submissions/#{submission.id}")
      expect(page).to have_content('Offer deleted')
    end

    it 'does not display the delete button if not in draft state' do
      offer.update!(state: 'sent')
      page.visit "/admin/offers/#{offer.id}"
      expect(page).to_not have_selector('#offer-delete-button')
    end

    it 'shows information about the submission' do
      expect(page).to have_content 'Submission'
      within(:css, '.list-item--submission') do
        expect(page).to have_content('Andy Warhol')
        expect(page).to_not have_content('artist1')
      end
    end

    it 'does not show an offer responses section if there are not any' do
      expect(page).to_not have_content('Offer responses')
    end

    describe 'save & send' do
      it 'shows the save & send button when offer is in draft state' do
        offer.update!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Save & Send')
        expect(page).to have_selector('.offer-draft-actions')
      end

      it 'does not show the save & send button after the offer has been sent' do
        offer.update!(state: 'sent')
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to_not have_content('Save & Send')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to save the offer' do
        stub_gravity_artist(id: submission.artist_id)
        offer.update!(state: 'draft')
        page.visit "/admin/offers/#{offer.id}"
        click_link('Save & Send')
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_content('Save & Send')

        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.to).to eq(%w[user@example.com])
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(emails.first.subject).to eq('Great news! You have a new offer.')
      end
    end

    describe 'offer lapsed' do
      before do
        offer.update!(state: 'sent')
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

    describe 'offer in review' do
      before do
        offer.update!(state: 'sent')
        stub_gravity_root
        stub_gravity_user(id: offer.submission.user.gravity_user_id)
        stub_gravity_user_detail(
          email: 'michael@bluth.com', id: offer.submission.user.gravity_user_id
        )
        stub_gravity_artist(id: submission.artist_id)
        stub_gravity_partner(id: partner.gravity_partner_id)
        stub_gravity_partner_communications(
          partner_id: partner.gravity_partner_id
        )
        stub_gravity_partner_contacts(
          partner_id: partner.gravity_partner_id,
          override_body: [
            { email: 'contact1@partner.com' },
            { email: 'contact2@partner.com' }
          ]
        )
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the mark in-review offer button' do
        expect(page).to_not have_content('Save & Send')
        expect(page).to have_content('Consignor Interested')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to mark the offer as in review' do
        expect(page).to have_selector('.offer-review-button')
        click_link('Consignor Interested')
        within('[data-remodal-id="interested-modal"]') do
          click_button('Save and Send')
        end
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_selector('.offer-review-button')

        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        expect(emails.map(&:to).flatten).to eq(
          %w[contact1@partner.com contact2@partner.com]
        )
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(emails.first.subject).to eq(
          'The consignor has expressed interest in your offer'
        )
      end

      it 'allows you to provide an override e-mail' do
        click_link('Consignor Interested')
        within('[data-remodal-id="interested-modal"]') do
          fill_in('offer_override_email', with: 'override@partner.com')
          click_button('Save and Send')
        end
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.map(&:to).flatten).to eq(%w[override@partner.com])
      end
    end

    describe 'offer consigned' do
      before do
        offer.update!(state: 'review')
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the accept offer button' do
        expect(page).to have_content('Accept Offer')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to have_selector('.offer-actions')
      end

      it 'allows you to mark the offer as consigned', js: true do
        expect(find('input#terms_signed')).to_not be_checked
        expect(page).to have_selector('.offer-consign-button.disabled-button')
        find('input#terms_signed').click
        expect(page).to_not have_selector(
                              '.offer-consign-button.disabled-button'
                            )
        find('.offer-consign-button').click
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to_not have_content('Accept Offer')
        expect(page).to have_selector('.list-item--consignment')

        # FIXME: Why do these two lines cause test to fail
        find('.list-item--consignment').click
        expect(page.current_path).to include('/admin/consignment')
      end
    end

    describe 'offer locked' do
      before do
        accepted_offer =
          Fabricate(:offer, partner_submission: partner_submission)
        offer.update!(state: 'review')
        OfferService.consign!(accepted_offer)
        stub_gravity_artist(id: submission.artist_id)
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows no actions' do
        expect(page).to have_content('State review')
        expect(page).to have_content('This offer is locked')
        expect(page).to_not have_selector('.offer-draft-actions')
      end
    end

    describe 'offer rejected' do
      before do
        offer.update!(state: 'sent')
        stub_gravity_root
        stub_gravity_user(id: offer.submission.user.gravity_user_id)
        stub_gravity_user_detail(
          email: 'michael@bluth.com', id: offer.submission.user.gravity_user_id
        )
        stub_gravity_artist(id: submission.artist_id)
        stub_gravity_partner(id: partner.gravity_partner_id)
        stub_gravity_partner_communications(
          partner_id: partner.gravity_partner_id
        )
        stub_gravity_partner_contacts(
          partner_id: partner.gravity_partner_id,
          override_body: [
            { email: 'contact1@partner.com' },
            { email: 'contact2@partner.com' }
          ]
        )
        page.visit "/admin/offers/#{offer.id}"
      end

      it 'shows the reject offer button' do
        expect(page).to_not have_content('Save & Send')
        expect(page).to have_content('Reject Offer')
      end

      it 'allows you to mark the offer as rejected with a note' do
        click_link('Reject Offer')
        within('[data-remodal-id="reject-offer-modal"]') do
          choose('offer_rejection_reason_low_estimate')
          click_button('Save and Send')
        end
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content('Undo Offer Rejection')
        expect(page).to_not have_content('Reject Offer')
        expect(page).to have_content('Rejected by Lucille Bluth. Low estimate')
        expect(page).to_not have_selector('.offer-draft-actions')
        expect(page).to_not have_selector('.offer-actions')

        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        expect(emails.map(&:to).flatten).to eq(
          %w[contact1@partner.com contact2@partner.com]
        )
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(emails.first.subject).to eq(
          'A response to your consignment offer'
        )
      end

      it 'allows you to add notes to the rejection' do
        click_link('Reject Offer')
        within('[data-remodal-id="reject-offer-modal"]') do
          choose('offer_rejection_reason_other')
          fill_in(
            'offer_rejection_note',
            with: 'The user has issues with who the partner is.'
          )
          click_button('Save and Send')
        end
        expect(page).to have_content(
          'Rejected by Lucille Bluth. Other: The user has issues with who the partner is.'
        )

        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        expect(emails.map(&:to).flatten).to eq(
          %w[contact1@partner.com contact2@partner.com]
        )
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(emails.first.subject).to eq(
          'A response to your consignment offer'
        )
      end

      it 'allows you to provide an override e-mail' do
        click_link('Reject Offer')
        within('[data-remodal-id="reject-offer-modal"]') do
          choose('offer_rejection_reason_low_estimate')
          fill_in('offer_override_email', with: 'override@partner.com')
          click_button('Save and Send')
        end
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.map(&:to).flatten).to eq(%w[override@partner.com])
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(emails.first.subject).to eq(
          'A response to your consignment offer'
        )
      end
    end

    describe 'offer with responses' do
      it 'shows a rejected response' do
        Fabricate(
          :offer_response,
          offer: offer,
          intended_state: Offer::REJECTED,
          rejection_reason: 'Low estimate'
        )
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Offer responses')
        expect(page).to_not have_content('Comments:')
        expect(page).to_not have_content('Phone number:')
        expect(page).to have_content('Reject offer')
        expect(page).to have_content('Reason: Low estimate')

        # In the sidebar
        expect(page).to have_content('Most recent offer response Reject offer')
      end

      it 'shows an accepted response' do
        Fabricate(
          :offer_response,
          offer: offer, intended_state: Offer::ACCEPTED
        )
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Offer responses')
        expect(page).to_not have_content('Comments:')
        expect(page).to_not have_content('Phone number:')
        expect(page).to have_content('Accept offer')
        expect(page).to_not have_content('Reason: ')

        # In the sidebar
        expect(page).to have_content('Most recent offer response Accept offer')
      end

      it 'shows an interested response' do
        Fabricate(
          :offer_response,
          offer: offer,
          intended_state: Offer::REVIEW,
          comments: 'Super interested but have questions.',
          phone_number: '123-456-789'
        )
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Offer responses')
        expect(page).to have_content(
          'Comments: Super interested but have questions.'
        )
        expect(page).to have_content('Phone number: 123-456-789')
        expect(page).to have_content('Interested in offer')
        expect(page).to_not have_content('Reason: ')

        # In the sidebar
        expect(page).to have_content(
          'Most recent offer response Interested in offer'
        )
      end

      it 'shows multiple responses' do
        Fabricate(
          :offer_response,
          offer: offer,
          intended_state: Offer::REVIEW,
          comments: 'Super interested but have questions.',
          phone_number: '123-456-789'
        )
        Fabricate(
          :offer_response,
          offer: offer, intended_state: Offer::ACCEPTED
        )
        page.visit "/admin/offers/#{offer.id}"
        expect(page).to have_content('Offer responses')
        expect(page).to have_content('Interested in offer')
        expect(page).to have_content('Accept offer')

        # In the sidebar
        expect(page).to have_content('Most recent offer response Accept offer')
      end
    end
  end
end
