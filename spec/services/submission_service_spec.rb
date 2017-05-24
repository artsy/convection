require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionService do
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
      expect(emails.first.html_part.body).to include('My Artwork')
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
