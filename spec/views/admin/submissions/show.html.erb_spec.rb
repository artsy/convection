require 'rails_helper'
require 'support/gravity_helper'
require 'support/jwt_helper'

describe 'admin/submissions/show.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
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
        user_id: 'userid',
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

    it 'displays the reviewer byline if the submission has been approved' do
      @submission.update_attributes!(state: 'approved', approved_by: 'userid', approved_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Approved by Jon Jonson'
    end

    it 'displays the reviewer byline if the submission has been rejected' do
      @submission.update_attributes!(state: 'rejected', rejected_by: 'userid', rejected_at: Time.now.utc)
      page.visit "/admin/submissions/#{@submission.id}"
      expect(page).to have_content 'Rejected by Jon Jonson'
    end

    it 'does not display partners who have not been notified' do
      allow(Convection.config).to receive(:consignment_communication_id).and_return('comm1')
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
      allow(Convection.config).to receive(:consignment_communication_id).and_return('comm1')
      partner1 = Fabricate(:partner, gravity_partner_id: 'partnerid')
      partner2 = Fabricate(:partner, gravity_partner_id: 'phillips')
      SubmissionService.update_submission(@submission, state: 'approved')
      stub_gravity_partner(id: 'partnerid')
      stub_gravity_partner(id: 'phillips')
      stub_gravity_partner_contacts(partner_id: 'partnerid')
      stub_gravity_partner_contacts(partner_id: 'phillips')
      PartnerSubmissionService.daily_digest
      page.visit "/admin/submissions/#{@submission.id}"

      expect(page).to have_content('Partner Interest')
      expect(page).to have_content("#{partner1.id} notified on")
      expect(page).to have_content("#{partner2.id} notified on")
    end

    context 'unreviewed submission' do
      it 'displays buttons to approve/reject if the submission is not yet reviewed' do
        expect(page).to have_content('Approve')
        expect(page).to have_content('Reject')
      end

      it 'approves a submission when the Approve button is clicked' do
        click_link 'Approve'
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('Your submission has been approved!')
        expect(page).to have_content 'Approved by Jon Jonson'
        expect(page).to_not have_content 'Reject'
      end

      it 'rejects a submission when the Approve button is clicked' do
        click_link 'Reject'
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('So sorry your submission has been rejected.')
        expect(page).to have_content 'Rejected by Jon Jonson'
        expect(page).to_not have_content 'Approve'
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
    end
  end
end
