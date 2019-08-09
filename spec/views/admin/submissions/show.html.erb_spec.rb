require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/submissions/show.html.erb', type: :feature do
  before do
    allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
  end

  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
      allow(Convection.config).to receive(:auction_offer_form_url).and_return('https://google.com/auction')
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail
      stub_gravity_artist

      @submission = Fabricate(:submission,
        title: 'my sartwork',
        artist_id: 'artistid',
        edition: true,
        edition_size: 100,
        edition_number: '23a',
        category: 'Painting',
        user: Fabricate(:user, gravity_user_id: 'userid'),
        state: 'submitted')

      stub_jwt_header('userid')
      page.visit "/admin/submissions/#{@submission.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Submission ##{@submission.id}")
      expect(page).to have_content('Gob Bluth')
      expect(page).to have_content('Jon Jonson')
      expect(page).to have_content('user@example.com')
      expect(page).to have_content('Painting')
    end

    it 'displays no undo links' do
      expect(page).to_not have_content 'Undo approval'
      expect(page).to_not have_content 'Undo rejection'
      expect(page).to_not have_content 'Undelete submission'
    end

    it 'displays a delete submission link' do
      expect(page).to have_content('Delete submission')
    end

    it 'displays No for price in mind if there is no minimum_price' do
      within('.minimum-price') do
        expect(page).to have_content('No')
      end
    end

    it 'displays a formatted minimum_price if present' do
      @submission.update!(minimum_price_cents: 5_000 * 100)
      page.visit "/admin/submissions/#{@submission.id}"
      within('.minimum-price') do
        expect(page).to have_content('Yes, $5,000')
      end
    end

    it 'displays the reviewer byline if the submission has been approved' do
      @submission.update!(state: 'approved', approved_by: 'userid', approved_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Approved by Jon Jonson'
    end

    it 'displays the undo approval link if the submission has been approved' do
      @submission.update!(state: 'approved', approved_by: 'userid', approved_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Undo approval'
      expect(page).to_not have_content 'Undo rejection'
    end

    it 'displays the undelete submission link and informs the user the submission is deleted if the submission has been deleted' do
      @submission.update!(deleted_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Undelete submission'
      expect(page).to have_content '(Deleted)'
    end

    it 'displays the reviewer byline if the submission has been rejected' do
      @submission.update!(state: 'rejected', rejected_by: 'userid', rejected_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Rejected by Jon Jonson'
    end

    it 'displays the undo rejection link if the submission has been approved' do
      @submission.update!(state: 'rejected', rejected_by: 'userid', rejected_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Undo rejection'
      expect(page).to_not have_content 'Undo approval'
    end

    it 'does not display partners who have not been notified' do
      expect(NotificationService).to receive(:post_submission_event).once.with(@submission.id, 'approved')
      partner1 = Fabricate(:partner, gravity_partner_id: 'partnerid')
      partner2 = Fabricate(:partner, gravity_partner_id: 'phillips')
      SubmissionService.update_submission(@submission, state: 'approved')
      expect(@submission.partner_submissions.count).to eq 2
      page.visit "/admin/submissions/#{@submission.id}"

      expect(page).to have_content('Partner Interest')
      expect(page).to_not have_content("#{partner1.id} notified on")
      expect(page).to_not have_content("#{partner2.id} notified on")
    end

    it 'displays the partners that a submission has been shown to' do
      expect(NotificationService).to receive(:post_submission_event).once.with(@submission.id, 'approved')
      stub_gravity_partner_communications
      stub_gravity_partner_contacts
      partner1 = Fabricate(:partner, gravity_partner_id: 'partnerid')
      partner2 = Fabricate(:partner, gravity_partner_id: 'phillips')
      gravql_partners_response = {
        data: {
          partners: [
            { id: partner1.gravity_partner_id, given_name: 'Partner 1' },
            { id: partner2.gravity_partner_id, given_name: 'Phillips' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_partners_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )
      SubmissionService.update_submission(@submission, state: 'approved')
      stub_gravity_partner(id: 'partnerid')
      stub_gravity_partner(id: 'phillips')
      stub_gravity_partner_contacts(partner_id: 'partnerid')
      stub_gravity_partner_contacts(partner_id: 'phillips')
      PartnerSubmissionService.daily_digest
      page.visit "/admin/submissions/#{@submission.id}"

      expect(page).to have_content('Partner Interest')
      expect(page).to have_content('2 partners notified on')
    end

    it 'does not display the consignment list item if there is no consignment' do
      expect(page).to_not have_selector('.list-item--consignment')
    end

    context 'unreviewed submission' do
      it 'displays buttons to approve/reject if the submission is not yet reviewed' do
        expect(page).to have_content('Approve')
        expect(page).to have_content('Reject')
      end

      it 'approves a submission when the Approve button is clicked' do
        expect(NotificationService).to receive(:post_submission_event).once.with(@submission.id, 'approved')
        expect(page).to_not have_content('Create Offer')
        expect(page).to have_content('submitted')
        click_link 'Approve'
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include(
          'Your work is currently being reviewed for consignment by our network of trusted partners'
        )
        expect(page).to have_content 'Approved by Jon Jonson'
        expect(page).to_not have_content 'Reject'
        expect(page).to have_content('approved')
        expect(page).to have_content('Create Offer')
      end

      it 'rejects a submission when the Reject button is clicked' do
        expect(page).to have_content('submitted')
        click_link 'Reject'
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include(
          'they do not have a market for this work at the moment'
        )
        expect(page).to have_content 'Rejected by Jon Jonson'
        expect(page).to_not have_content 'Approve'
        expect(page).to have_content('rejected')
        expect(page).to_not have_content('Create Offer')
      end

      describe 'undo actions' do
        let(:submission2) do
          Fabricate(:submission,
            title: 'THE SECOND ARTWORK',
            artist_id: 'artistid',
            edition: true,
            edition_size: 100,
            edition_number: '23a',
            category: 'Painting',
            user: Fabricate(:user, gravity_user_id: 'userid3'),
            state: 'submitted')
        end
        before do
          partner = Fabricate(:partner, gravity_partner_id: 'partnerid')
          Fabricate(:partner, gravity_partner_id: 'phillips')
          stub_gravity_user(id: 'userid3')
          stub_gravity_user_detail(id: 'userid3')
          stub_gravity_partner(id: 'partnerid')
          stub_gravity_partner(id: 'phillips')
          stub_gravity_partner_contacts(partner_id: 'partnerid')
          stub_gravity_partner_contacts(partner_id: 'phillips')
          stub_gravity_partner_contacts(
            partner_id: partner.gravity_partner_id,
            override_body: [
              { email: 'contact1@partner.com' },
              { email: 'contact2@partner.com' }
            ]
          )
          stub_gravity_partner_communications
        end

        it 'removes the work from the digest when Undo approval is clicked' do
          expect(NotificationService).to receive(:post_submission_event).once.with(@submission.id, 'approved')
          expect(NotificationService).to receive(:post_submission_event).once.with(submission2.id, 'approved')
          SubmissionService.update_submission(@submission, state: 'approved')
          SubmissionService.update_submission(submission2, state: 'approved')
          expect(@submission.partner_submissions.count).to eq 2
          expect(submission2.partner_submissions.count).to eq 2
          page.visit "/admin/submissions/#{@submission.id}"

          click_link 'Undo approval'
          expect(page).to have_content 'Approve'
          expect(@submission.partner_submissions.count).to eq 0
          ActionMailer::Base.deliveries = []
          expect { PartnerSubmissionService.daily_digest }.to change { ActionMailer::Base.deliveries.length }

          email = ActionMailer::Base.deliveries.first

          expect(email.html_part.body).to include(submission2.title)
          expect(email.html_part.body).to_not include(@submission.title)
        end
      end
    end

    context 'with assets' do
      before do
        4.times do
          Fabricate(:image, submission: @submission, gemini_token: nil)
        end
        page.visit "/admin/submissions/#{@submission.id}"
      end

      it 'displays all of the assets' do
        expect(page).to have_selector('.list-group-item', count: 4)
      end

      it 'lets you click an asset' do
        asset = @submission.assets.first
        click_link("image ##{asset.id}")
        expect(page).to have_content("Asset ##{asset.id}")
        expect(page).to have_content("Submission ##{@submission.id}")
        expect(page).to_not have_content('View Original')
      end

      it 'displays make primary if there are no primary assets' do
        expect(page).to_not have_selector('.primary-image-label')
        expect(page).to have_selector('.make-primary-image', count: 4)
      end

      it 'lets you remove an existing asset', js: true do
        asset = @submission.assets.first
        selector = "div#submission-asset-#{asset.id}"

        within(selector) do
          click_link('Remove')
        end

        page.driver.browser.switch_to.alert.accept

        expect(page).to_not have_selector(selector)
      end

      it 'displays the primary asset label and respects changing it' do
        primary_image = @submission.assets.first
        @submission.update!(primary_image_id: primary_image.id)
        page.visit "/admin/submissions/#{@submission.id}"
        within("div#submission-asset-#{primary_image.id}") do
          expect(page).to have_selector('.primary-image-label', count: 1)
          expect(page).to_not have_selector('.make-primary-image')
        end
        expect(page).to have_selector('.make-primary-image', count: 3)

        # clicking make primary changes the primary asset
        new_primary_image = @submission.assets.last
        page.visit "/admin/submissions/#{@submission.id}"
        within("div#submission-asset-#{new_primary_image.id}") do
          expect(page).to_not have_selector('.primary-image-label')
          click_link('Make primary')
        end
        expect(page).to have_selector('.make-primary-image', count: 3)
        within("div#submission-asset-#{primary_image.id}") do
          expect(page).to_not have_selector('.primary-image-label')
        end
        within("div#submission-asset-#{new_primary_image.id}") do
          expect(page).to have_selector('.primary-image-label')
        end
      end
    end

    context 'with a consignment' do
      before do
        consignment = Fabricate(:partner_submission, submission: @submission, state: 'open')
        @submission.update!(consigned_partner_submission: consignment)
        page.visit admin_submission_path(@submission)
      end

      it 'shows the consignment' do
        expect(page).to have_selector('.list-item--consignment')
        expect(page).to have_content('Consignment')

        within(:css, '.list-item--consignment') do
          expect(page).to have_content('Gob Bluth')
        end
      end
    end
  end
end
