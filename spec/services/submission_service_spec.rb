require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionService do
  let!(:user) { Fabricate(:user, gravity_user_id: 'userid', email: 'michael@bluth.com') }
  let(:submission) do
    Fabricate(:submission, artist_id: 'artistid', user: user, title: 'My Artwork')
  end

  before do
    stub_gravity_root
    stub_gravity_user
    stub_gravity_user_detail(email: 'michael@bluth.com')
    stub_gravity_artist
  end

  context 'create_submission' do
    let(:params) { { artist_id: 'artistid', state: 'draft', title: 'My Artwork' } }

    it 'creates a submission and sets the user_id and email' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail(email: 'michael@bluth.com')
      stub_gravity_artist

      new_submission = SubmissionService.create_submission(params, 'userid')
      expect(new_submission.reload.state).to eq 'draft'
      expect(new_submission.user_id).to eq user.id
      expect(new_submission.user.email).to eq 'michael@bluth.com'
    end

    it 'raises an exception if the user_detail cannot be found' do
      stub_gravity_root
      stub_request(:get, "#{Convection.config.gravity_api_url}/user_details/foo")
        .to_raise(Faraday::ResourceNotFound)

      expect do
        SubmissionService.create_submission(params, 'foo')
      end.to raise_error(Faraday::ResourceNotFound)
    end

    it 'raises an error if the email is blank' do
      stub_gravity_root
      stub_gravity_user(id: 'foo')
      stub_gravity_user_detail(id: 'foo', email: '')

      expect do
        SubmissionService.create_submission(params, 'foo')
      end.to raise_error('User lacks email.')
    end
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
      Fabricate(:image, submission: submission)
      SubmissionService.update_submission(submission, state: 'submitted')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 2
    end

    it 'sends no emails if the state is not being changed' do
      SubmissionService.update_submission(submission, { title: 'Updated Artwork Title', state: 'draft' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.title).to eq 'Updated Artwork Title'
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end

    it 'sends no emails if the state is not being changed to approved or rejected' do
      SubmissionService.update_submission(submission, { state: 'draft' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end

    it 'sends an approval notification if the submission state is changed to approved' do
      SubmissionService.update_submission(submission, { state: 'approved' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
      expect(emails.first.to).to eq(['michael@bluth.com'])
      expect(emails.first.html_part.body).to include(
        'Your work is currently being reviewed for consignment by our network of trusted partners'
      )
      expect(submission.state).to eq 'approved'
      expect(submission.approved_by).to eq 'userid'
      expect(submission.approved_at).to_not be_nil
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
    end

    it 'generates partner submissions on an approval' do
      partner1 = Fabricate(:partner, gravity_partner_id: 'partner1')
      partner2 = Fabricate(:partner, gravity_partner_id: 'partner2')

      SubmissionService.update_submission(submission, { state: 'approved' }, 'userid')
      expect(ActionMailer::Base.deliveries.length).to eq 1
      expect(partner1.partner_submissions.length).to eq 1
      expect(partner2.partner_submissions.length).to eq 1
      expect(partner1.partner_submissions.first.notified_at).to be_nil
      expect(partner2.partner_submissions.first.notified_at).to be_nil
    end

    it 'sends a rejection notification if the submission state is changed to rejected' do
      SubmissionService.update_submission(submission, { state: 'rejected' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
      expect(emails.first.to).to eq(['michael@bluth.com'])
      expect(emails.first.from).to eq(['consign@artsy.net'])
      expect(emails.first.html_part.body).to include(
        'they do not have a market for this work at the moment'
      )
      expect(submission.state).to eq 'rejected'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end
  end

  context 'notify_user' do
    describe 'with assets' do
      before do
        Fabricate(:image, submission: submission)
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
        submission.update!(receipt_sent_at: Time.now.utc)
        expect do
          SubmissionService.notify_user(submission.id)
        end.to_not change(ActionMailer::Base.deliveries, :count)
      end
    end

    describe 'without assets' do
      it 'sends the first reminder if no reminders have been sent yet' do
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.html_part.body).to include('Complete your consignment submission')
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e01')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 1
      end

      it 'sends the second reminder if one reminder has been sent' do
        submission.update!(reminders_sent_count: 1)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.html_part.body).to include("We're missing photos of your work")
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e02')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 2
      end

      it 'sends the third reminder if two reminders have ben sent' do
        submission.update!(reminders_sent_count: 2)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.html_part.body).to include("We're unable to complete your submission")
        expect(emails.first.html_part.body).to include('utm_campaign=consignment-complete')
        expect(emails.first.html_part.body).to include('utm_source=drip-consignment-reminder-e03')
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 3
      end

      it 'does not send a reminder if a receipt has already been sent' do
        submission.update!(reminders_sent_count: 1, receipt_sent_at: Time.now.utc)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end

      it 'does not send a reminder if three reminders have already been sent' do
        submission.update!(reminders_sent_count: 3)
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
      submission.update!(admin_receipt_sent_at: Time.now.utc)
      expect do
        SubmissionService.notify_admin(submission.id)
      end.to_not change(ActionMailer::Base.deliveries, :count)
    end
  end

  context 'deliver_submission_receipt' do
    it 'raises an exception if the submission cannot be found' do
      expect do
        SubmissionService.deliver_submission_receipt('foo')
      end.to raise_error("Couldn't find Submission with 'id'=foo")
    end

    it 'raises an exception if all of the images have not been processed' do
      submission.update!(receipt_sent_at: Time.now.utc)
      Fabricate(:unprocessed_image, submission: submission)
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

      submission.update!(receipt_sent_at: Time.now.utc - 20.minutes)
      Fabricate(:unprocessed_image, submission: submission)
      SubmissionService.deliver_submission_receipt(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to include('consignments-archive@artsymail.com', 'lucille@bluth.com')
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
      submission.update!(receipt_sent_at: Time.now.utc)
      Fabricate(:unprocessed_image, submission: submission)
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
      submission.update!(receipt_sent_at: Time.now.utc - 20.minutes)
      Fabricate(:unprocessed_image, submission: submission)
      SubmissionService.deliver_submission_notification(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('My Artwork')
    end
  end
end
