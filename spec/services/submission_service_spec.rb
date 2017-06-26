require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionService do
  let(:submission) do
    Submission.create!(
      artist_id: 'artistid',
      user_id: 'userid',
      title: 'My Artwork',
      medium: 'painting',
      year: '1992',
      height: '12',
      width: '14',
      dimensions_metric: 'in',
      location_city: 'New York',
      category: 'Painting'
    )
  end

  before do
    stub_gravity_root
    stub_gravity_user
    stub_gravity_user_detail(email: 'michael@bluth.com')
    stub_gravity_artist
  end

  context 'update_submission' do
    it 'sends no emails of the submission is not being submitted' do
      SubmissionService.update_submission(submission, state: 'draft')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    it 'sends a reminder if the submission has no images' do
      expect(NotificationService).to receive(:post_submission_event).once.with(submission.id, 'submitted')
      SubmissionService.update_submission(submission, state: 'submitted')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 4
    end

    it 'sends no reminders if the submission has images' do
      expect(NotificationService).to receive(:post_submission_event).once.with(submission.id, 'submitted')
      submission.assets.create!(asset_type: 'image', image_urls: { square: 'http://square.jpg' })
      SubmissionService.update_submission(submission, state: 'submitted')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 2
    end
  end

  context 'notify_user' do
    describe 'with assets' do
      before do
        submission.assets.create!(asset_type: 'image', image_urls: { square: 'http://square.jpg' })
      end

      it 'sends a receipt' do
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('Thank you for submitting your work to our consignments network')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(submission.reload.receipt_sent_at).to_not be nil
      end

      it 'does not send a receipt if one has already been sent' do
        submission.update_attributes!(receipt_sent_at: Time.now.utc)
        expect do
          SubmissionService.notify_user(submission.id)
        end.to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    describe 'without assets' do
      it 'sends the first reminder if no reminders have been sent yet' do
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('Complete your consignment submission')
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e01')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 1
      end

      it 'sends the second reminder if one reminder has been sent' do
        submission.update_attributes!(reminders_sent_count: 1)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include("We're missing photos of your work")
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e02')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 2
      end

      it 'sends the third reminder if two reminders have ben sent' do
        submission.update_attributes!(reminders_sent_count: 2)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('We’re unable to complete your submission')
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e03')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 3
      end

      it 'does not send a reminder if a receipt has already been sent' do
        submission.update_attributes!(reminders_sent_count: 1, receipt_sent_at: Time.now.utc)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end

      it 'does not send a reminder if three reminders have already been sent' do
        submission.update_attributes!(reminders_sent_count: 3)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end
    end
  end

  context 'notify_admin' do
    it 'sends an email if one has not been sent' do
      expect(NotificationService).to receive(:post_submission_event).once.with(submission.id, 'submitted')
      SubmissionService.notify_admin(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('My Artwork')
      expect(emails.first.to).to eq(['consign@artsy.net'])
      expect(submission.reload.admin_receipt_sent_at).to_not be nil
    end

    it 'does not send an email if one has already been sent' do
      submission.update_attributes!(admin_receipt_sent_at: Time.now.utc)
      expect do
        SubmissionService.notify_admin(submission.id)
      end.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  context 'deliver_submission_receipt' do
    it 'raises an exception if the submission cannot be found' do
      expect do
        SubmissionService.deliver_submission_receipt('foo')
      end.to raise_error("Couldn't find Submission with 'id'=foo")
    end

    it 'raises an exception if all of the images have not been processed' do
      submission = Submission.create!(title: 'My Artwork', receipt_sent_at: Time.now.utc)
      submission.assets.create!(asset_type: 'image')
      expect do
        SubmissionService.deliver_submission_receipt(submission.id)
      end.to raise_error('Still processing images.')
    end

    it 'sends an email if the enough time has passed since the initial attempt' do
      allow(Convection.config).to receive(:processing_grace_seconds).and_return(600)
      allow(Convection.config).to receive(:admin_email_address).and_return('lucille@bluth.com')
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist

      submission = Submission.create!(
        title: 'My Artwork',
        receipt_sent_at: Time.now.utc - 20.minutes,
        artist_id: 'artistid',
        user_id: 'userid'
      )
      submission.assets.create!(asset_type: 'image')
      SubmissionService.deliver_submission_receipt(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('Thank you for submitting your work to our consignments network')
    end
  end

  context 'deliver_submission_notification' do
    it 'raises an exception if the submission cannot be found' do
      expect do
        SubmissionService.deliver_submission_notification('foo')
      end.to raise_error("Couldn't find Submission with 'id'=foo")
    end

    it 'raises an exception if all of the images have not been processed' do
      submission = Submission.create!(title: 'My Artwork', receipt_sent_at: Time.now.utc)
      submission.assets.create!(asset_type: 'image')
      expect do
        SubmissionService.deliver_submission_notification(submission.id)
      end.to raise_error('Still processing images.')
    end

    it 'sends an email if the enough time has passed since the initial attempt' do
      allow(Convection.config).to receive(:processing_grace_seconds).and_return(600)
      allow(Convection.config).to receive(:admin_email_address).and_return('lucille@bluth.com')
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist
      submission = Submission.create!(
        title: 'My Artwork',
        receipt_sent_at: Time.now.utc - 20.minutes,
        artist_id: 'artistid',
        user_id: 'userid'
      )
      submission.assets.create!(asset_type: 'image')
      SubmissionService.deliver_submission_notification(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('My Artwork')
    end
  end
end
