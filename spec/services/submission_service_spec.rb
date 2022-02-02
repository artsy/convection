# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe SubmissionService do
  let!(:user) do
    Fabricate(:user, gravity_user_id: 'userid', email: 'michael@bluth.com')
  end
  let!(:admin) do
    Fabricate(:admin_user, gravity_user_id: 'userid1', email: 'admin@bluth.com')
  end
  let(:submission) do
    Fabricate(
      :submission,
      artist_id: 'artistid',
      user: user,
      title: 'My Artwork'
    )
  end

  before { add_default_stubs }

  context 'create_submission' do
    let(:params) do
      {
        artist_id: 'artistid',
        state: 'submitted',
        title: 'My Artwork',
        user_name: 'michael',
        user_email: 'michael@bluth.com',
        user_phone: '555-5555'
      }
    end

    it 'creates a submission with state Rejected when artist is not in target supply' do
      new_submission =
        SubmissionService.create_submission(
          params,
          'userid',
          is_convection: false
        )
      expect(new_submission.reload.state).to eq 'rejected'
    end

    it 'delvers rejection email to user for non-target supply artist submissions' do
      new_submission =
        SubmissionService.create_submission(
          params,
          'userid',
          is_convection: false
        )
      expect(new_submission.reload.state).to eq 'rejected'

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include(
        'Specialists have determined we cannot accept'
      )
    end

    it 'does not reject a submission automatically, when created by Convection' do
      new_submission =
        SubmissionService.create_submission(
          params,
          'userid',
          is_convection: true
        )

      expect(new_submission.reload.state).to eq 'submitted'
    end

    it 'creates a submission and sets the user_id and email' do
      new_submission = SubmissionService.create_submission(params, 'userid')
      expect(new_submission.reload.state).to eq 'submitted'
      expect(new_submission.user_id).to eq user.id
      expect(new_submission.user.email).to eq 'michael@bluth.com'
    end

    it 'does not populate admin field, when submission is made by non-admin' do
      new_submission = SubmissionService.create_submission(params, 'userid')
      expect(new_submission.reload.admin).to eq nil
    end

    it 'populates admin field, when submission is made by admin' do
      new_submission =
        SubmissionService.create_submission(
          params,
          'userid',
          is_convection: true,
          current_user: admin.gravity_user_id
        )

      expect(new_submission.reload.admin.id).to eq admin.id
      expect(new_submission.reload.admin.email).to eq admin.email
    end

    it 'creates a submission and sets the user_id if new convection user' do
      stub_gravity_root
      stub_gravity_user(id: 'user_id')
      stub_gravity_user_detail(id: 'user_id', email: 'michael1@bluth.com')
      stub_gravity_artist

      new_submission = SubmissionService.create_submission(params, 'user_id')

      expect(new_submission.reload.state).to eq 'submitted'
      expect(new_submission.user_id).to_not eq user.id
      expect(new_submission.user.email).to eq 'michael1@bluth.com'
    end

    context 'anonymous submission' do
      before do
        stub_gravity_user(id: 'anonymous', name: 'michael')
        stub_gravity_user_detail(
          email: 'michael@bluth.com',
          id: 'anonymous',
          phone: '555-5555'
        )
      end
      context 'create_submission' do
        it 'adds contact information to the user record' do
          new_submission = SubmissionService.create_submission(params, nil)
          expect(new_submission.user_name).to eq 'michael'
          expect(new_submission.user_email).to eq 'michael@bluth.com'
          expect(new_submission.user_phone).to eq '555-5555'
          expect(new_submission.count_submissions_of_user).to eq 1
          expect(new_submission.user).to eq nil
        end
      end
      context 'count_submissions_of_user' do
        it 'return 3 if we had 3 submission with the same user_email' do
          SubmissionService.create_submission(params, nil)
          SubmissionService.create_submission(params, nil)
          SubmissionService.create_submission(params, nil)
          expect(Submission.last.count_submissions_of_user).to eq 3
        end
      end
    end

    context 'draft submission' do
      let(:params) do
        {
          artist_id: 'artistid',
          state: 'draft',
          title: 'My Artwork',
          user_name: 'michael',
          user_email: 'michael@bluth.com',
          user_phone: '555-5555'
        }
      end

      it 'creates a submission with state Draft when artist is not in target supply' do
        stub_gravity_root
        stub_gravity_user
        stub_gravity_user_detail(email: 'michael@bluth.com')
        stub_gravity_artist({ name: 'some nonTarget artist' })

        new_submission =
          SubmissionService.create_submission(
            params,
            'userid',
            is_convection: false
          )
        expect(new_submission.reload.state).to eq 'draft'
      end
    end
  end

  context 'update_submission' do
    it 'sends no emails of the submission is not being submitted' do
      SubmissionService.update_submission(submission, state: 'draft')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    it 'sends a reminder if the submission has no images' do
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'submitted')
      SubmissionService.update_submission(submission, state: 'submitted')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 3
    end

    it 'sends no reminders if the submission has images' do
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'submitted')
      Fabricate(:image, submission: submission)
      SubmissionService.update_submission(submission, state: 'submitted')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 2
    end

    it 'sends no emails if the state is not being changed' do
      SubmissionService.update_submission(
        submission,
        { title: 'Updated Artwork Title', state: 'draft' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.title).to eq 'Updated Artwork Title'
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'sends no emails if the state is not being changed to published or rejected' do
      SubmissionService.update_submission(
        submission,
        { state: 'draft' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'sends an approval notification if the submission state is changed to approved' do
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'approved')
      SubmissionService.update_submission(
        submission,
        { state: 'approved' },
        current_user: 'userid'
      )
      expect(ActionMailer::Base.deliveries.length).to eq 0
      expect(submission.state).to eq 'approved'
      expect(submission.approved_by).to eq 'userid'
      expect(submission.approved_at).to_not be_nil
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'does not generate partner submissions on an approval' do
      allow(NotificationService).to receive(:post_submission_event)
      partner1 = Fabricate(:partner, gravity_partner_id: 'partner1')
      partner2 = Fabricate(:partner, gravity_partner_id: 'partner2')

      SubmissionService.update_submission(
        submission,
        { state: 'approved' },
        current_user: 'userid'
      )
      expect(ActionMailer::Base.deliveries.length).to eq 0
      expect(partner1.partner_submissions.length).to eq 0
      expect(partner2.partner_submissions.length).to eq 0
    end

    it 'generates partner submissions on publish' do
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'published')
      partner1 = Fabricate(:partner, gravity_partner_id: 'partner1')
      partner2 = Fabricate(:partner, gravity_partner_id: 'partner2')

      SubmissionService.update_submission(
        submission,
        { state: 'published' },
        current_user: 'userid'
      )

      expect(ActionMailer::Base.deliveries.length).to eq 1
      expect(partner1.partner_submissions.length).to eq 1
      expect(partner2.partner_submissions.length).to eq 1
      expect(partner1.partner_submissions.first.notified_at).to be_nil
      expect(partner2.partner_submissions.first.notified_at).to be_nil
    end

    it 'sets published_at date on publish' do
      allow(NotificationService).to receive(:post_submission_event)
      SubmissionService.update_submission(
        submission,
        { state: 'published' },
        current_user: 'userid'
      )

      expect(submission.published_at).to_not be_nil
    end

    it 'only updates published_at for already approved submissions on publish' do
      allow(NotificationService).to receive(:post_submission_event)
      approved_at = 1.day.ago.beginning_of_day
      submission.update!(
        state: 'approved',
        approved_at: approved_at,
        published_at: approved_at
      )
      SubmissionService.update_submission(
        submission,
        { state: 'published' },
        current_user: 'userid'
      )

      expect(submission.reload.approved_at).to eq approved_at
      expect(submission.reload.published_at).to_not be_nil
    end

    it 'sends a rejection notification if the submission state is changed to rejected' do
      SubmissionService.update_submission(
        submission,
        { state: 'rejected' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include(
        'Thank you for submission and interest in our'
      )
      expect(submission.state).to eq 'rejected'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'sends a fake rejection notification if the submission state is changed to rejected' do
      SubmissionService.update_submission(
        submission,
        { state: 'rejected', rejection_reason: 'Fake' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include('After extensive research')
      expect(submission.state).to eq 'rejected'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'sends a artist rejection notification if the submission state is changed to rejected' do
      SubmissionService.update_submission(
        submission,
        { state: 'rejected', rejection_reason: 'Artist Submission' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include(
        'If you are represented by a gallery that would be interested in partnering with Artsy'
      )
      expect(submission.state).to eq 'rejected'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'sends a artist rejection notification if the submission state is changed to rejected' do
      stub_gravity_artist({ name: 'some nonTarget artist' })

      SubmissionService.update_submission(
        submission,
        { state: 'rejected', rejection_reason: 'NSV' },
        current_user: 'userid'
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include(
        'Unfortunately, this artwork would fall below our auction threshold'
      )
      expect(submission.state).to eq 'rejected'
      expect(submission.rejection_reason).to eq 'NSV'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
      expect(submission.published_at).to be_nil
    end

    it 'updates the user associated with the submission if a user ID is passed' do
      new_user = Fabricate(:user, gravity_user_id: 'user_id3', email: nil)
      add_default_stubs(id: new_user.gravity_user_id)
      stub_gravity_user_detail(
        id: new_user.gravity_user_id,
        email: 'cool.cat@fatcat.com'
      )

      SubmissionService.update_submission(submission, { user_id: 'user_id3' })

      expect(submission.user_id).to eq new_user.id
      expect(submission.user.email).to eq 'cool.cat@fatcat.com'
    end

    it 'does not update the user associated with the submission if no ID is passed' do
      SubmissionService.update_submission(
        submission,
        { title: 'Excellent Artwork' }
      )
      expect(submission.user_id).to eq user.id
    end

    it 'updates submission to Rejected state when submission state changed and artist is not in target supply' do
      stub_gravity_artist({ name: 'some nonTarget artist' })

      SubmissionService.update_submission(
        submission,
        { state: 'submitted' },
        current_user: 'userid',
        is_convection: false
      )

      expect(submission.state).to eq 'rejected'
      expect(submission.rejection_reason).to eq 'Not Target Supply'

      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
      expect(emails.first.to).to eq(%w[michael@bluth.com])
      expect(emails.first.from).to eq(%w[consign@artsy.net])
      expect(emails.first.html_part.body).to include(
        'Specialists have determined we cannot accept'
      )
    end

    it 'updates submission to Submitted state when submission state changed and artist is in target supply' do
      stub_gravity_artist(target_supply: true)
      allow(submission.user).to receive(:save_submission_to_my_collection?)
        .and_return(nil)

      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'submitted')

      SubmissionService.update_submission(
        submission,
        { state: 'submitted' },
        current_user: 'userid',
        is_convection: false
      )

      expect(submission.state).to eq 'submitted'
      expect(submission.rejection_reason).to eq nil
    end

    it 'updates submission to Submitted state when submission state changed in Convection and artist is not in target supply' do
      stub_gravity_artist({ name: 'some nonTarget artist' })
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'submitted')

      SubmissionService.update_submission(
        submission,
        { state: 'submitted' },
        current_user: 'userid',
        is_convection: true
      )

      expect(submission.state).to eq 'submitted'
      expect(submission.rejection_reason).to eq nil
    end

    context 'anonymous submission' do
      let(:submission) do
        Fabricate(
          :submission,
          artist_id: 'artistid',
          user_id: nil,
          user: nil,
          title: 'My Artwork',
          user_name: 'michael',
          user_email: 'michael@bluth.com',
          user_phone: '555-5555'
        )
      end

      it 'updates submission to Submitted state' do
        stub_gravity_artist(target_supply: true)
        expect(NotificationService).to receive(:post_submission_event)
          .once
          .with(submission.id, 'submitted')

        SubmissionService.update_submission(
          submission,
          { state: 'submitted' },
          current_user: nil,
          is_convection: false
        )

        expect(submission.state).to eq 'submitted'
      end
    end

    Submission::REQUIRED_FIELDS_FOR_SUBMISSION.map do |field|
      it "raises an exception if submission have missing #{field}" do
        arguments = { state: 'submitted' }
        arguments[field] = nil

        expect {
          SubmissionService.update_submission(
            submission,
            arguments,
            current_user: 'userid'
          )
        }.to raise_error(
          SubmissionService::ParamError,
          'Missing fields for submission.'
        )
      end
    end
  end

  context 'undo' do
    describe 'with approved submission' do
      let!(:partner) { Fabricate(:partner, gravity_partner_id: 'partner1') }

      before do
        expect(NotificationService).to receive(:post_submission_event)
          .once
          .with(submission.id, 'approved')
        Fabricate(:image, submission: submission)
        SubmissionService.update_submission(
          submission,
          { state: 'approved' },
          current_user: 'userid'
        )
        Fabricate(:partner_submission, partner: partner, submission: submission)
      end

      it 'deletes partner submissions and sends no emails on an undo approval' do
        expect(submission.partner_submissions.length).to eq 1

        expect { SubmissionService.undo_approval(submission) }.to_not change {
                        ActionMailer::Base.deliveries.length
                      }

        submission.reload
        expect(submission.partner_submissions.length).to eq 0
        expect(submission.state).to eq 'submitted'
        expect(submission.approved_by).to be_nil
        expect(submission.approved_at).to be_nil
        expect(submission.rejected_by).to be_nil
        expect(submission.rejected_at).to be_nil
        expect(submission.published_at).to be_nil
      end

      it 'fails to undo an approval if there are any offers' do
        Fabricate(
          :offer,
          partner_submission: submission.partner_submissions.first
        )
        expect { SubmissionService.undo_approval(submission) }.to raise_error(
          SubmissionService::SubmissionError,
          'Undoing approval of a submission with offers is not allowed!'
        )
      end
    end

    describe 'with published submission' do
      before do
        expect(NotificationService).to receive(:post_submission_event)
          .once
          .with(submission.id, 'published')
        Fabricate(:partner, gravity_partner_id: 'partner1')
        Fabricate(:image, submission: submission)
        SubmissionService.update_submission(
          submission,
          { state: 'published' },
          current_user: 'userid'
        )
      end

      it 'deletes partner submissions and sends no emails on an undo publish' do
        expect(submission.partner_submissions.length).to eq 1

        expect { SubmissionService.undo_publish(submission) }.to_not change {
                        ActionMailer::Base.deliveries.length
                      }

        submission.reload
        expect(submission.partner_submissions.length).to eq 0
        expect(submission.state).to eq 'submitted'
        expect(submission.approved_by).to be_nil
        expect(submission.approved_at).to be_nil
        expect(submission.rejected_by).to be_nil
        expect(submission.rejected_at).to be_nil
        expect(submission.published_at).to be_nil
      end

      it 'fails to undo a publish if there are any offers' do
        Fabricate(
          :offer,
          partner_submission: submission.partner_submissions.first
        )
        expect { SubmissionService.undo_publish(submission) }.to raise_error(
          SubmissionService::SubmissionError,
          'Undoing publish of a submission with offers is not allowed!'
        )
      end
    end

    describe 'with rejected submission' do
      before do
        Fabricate(:partner, gravity_partner_id: 'partner1')
        Fabricate(:image, submission: submission)
        SubmissionService.update_submission(
          submission,
          { state: 'rejected' },
          current_user: 'userid'
        )
      end

      it 'sends no emails for an undo rejection' do
        expect(ActionMailer::Base.deliveries.length).to eq 1

        SubmissionService.undo_rejection(submission)
        submission.reload
        expect(submission.state).to eq 'submitted'
        expect(submission.approved_by).to be_nil
        expect(submission.approved_at).to be_nil
        expect(submission.rejected_by).to be_nil
        expect(submission.rejected_at).to be_nil
        expect(submission.published_at).to be_nil

        # no new emails
        expect(ActionMailer::Base.deliveries.length).to eq 1
      end
    end
  end

  context 'notify_user' do
    describe 'with assets' do
      before { Fabricate(:image, submission: submission) }

      it 'sends a receipt' do
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.html_part.body).to include('This is a confirmation')
        expect(emails.first.to).to eq(%w[michael@bluth.com])
        expect(submission.reload.receipt_sent_at).to_not be nil
      end

      it 'does not send a receipt if one has already been sent' do
        submission.update!(receipt_sent_at: Time.now.utc)
        expect { SubmissionService.notify_user(submission.id) }.to_not change(
                        ActionMailer::Base.deliveries,
                        :count
                      )
      end
    end

    describe 'without assets' do
      it 'sends the first reminder if no reminders have been sent yet' do
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
        expect(emails.first.html_part.body).to include('your submission')
        expect(emails.first.html_part.body).to include(
          'utm_campaign=consignment-complete'
        )
        expect(emails.first.html_part.body).to include(
          'utm_source=drip-consignment-reminder-e01'
        )
        expect(emails.first.to).to eq(%w[michael@bluth.com])
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 1
      end

      it 'sends the second reminder if one reminder has been sent' do
        submission.update!(reminders_sent_count: 1)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
        expect(emails.first.html_part.body).to include(
          "We're unable to complete your submission"
        )
        expect(emails.first.html_part.body).to include(
          'utm_campaign=consignment-complete'
        )
        expect(emails.first.html_part.body).to include(
          'utm_source=drip-consignment-reminder-e02-v2'
        )
        expect(emails.first.to).to eq(%w[michael@bluth.com])
        expect(emails.first.from).to eq(%w[consign@artsy.net])
        expect(submission.reload.receipt_sent_at).to be nil
        expect(submission.reload.reminders_sent_count).to eq 2
      end

      it 'does not send a reminder if a receipt has already been sent' do
        submission.update!(
          reminders_sent_count: 1,
          receipt_sent_at: Time.now.utc
        )
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end

      it 'does not send a reminder if two reminders have already been sent' do
        submission.update!(reminders_sent_count: 2)
        SubmissionService.notify_user(submission.id)
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end
    end
  end

  context 'notify_admin' do
    it 'sends an email if one has not been sent' do
      expect(NotificationService).to receive(:post_submission_event)
        .once
        .with(submission.id, 'submitted')
      SubmissionService.notify_admin(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('My Artwork')
      expect(emails.first.to).to eq(%w[consign@artsy.net])
      expect(submission.reload.admin_receipt_sent_at).to_not be nil
    end

    it 'does not send an email if one has already been sent' do
      submission.update!(admin_receipt_sent_at: Time.now.utc)
      expect { SubmissionService.notify_admin(submission.id) }.to_not change(
                      ActionMailer::Base.deliveries,
                      :count
                    )
    end
  end

  context 'deliver_submission_receipt' do
    it 'raises an exception if the submission cannot be found' do
      expect {
        SubmissionService.deliver_submission_receipt('foo')
      }.to raise_error("Couldn't find Submission with 'id'=foo")
    end

    it 'raises an exception if all of the images have not been processed' do
      submission.update!(receipt_sent_at: Time.now.utc)
      Fabricate(:unprocessed_image, submission: submission)
      expect {
        SubmissionService.deliver_submission_receipt(submission.id)
      }.to raise_error('Still processing images.')
    end

    it 'sends an email if the enough time has passed since the initial attempt' do
      allow(Convection.config).to receive(:processing_grace_seconds).and_return(
        600
      )
      allow(Convection.config).to receive(:admin_email_address).and_return(
        'lucille@bluth.com'
      )
      stub_gravity_artist

      submission.update!(receipt_sent_at: Time.now.utc - 20.minutes)
      Fabricate(:unprocessed_image, submission: submission)
      SubmissionService.deliver_submission_receipt(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.bcc).to include('consignments-archive@artsymail.com')
      expect(emails.first.html_part.body).to include('This is a confirmation')
    end
  end

  context 'deliver_submission_notification' do
    it 'raises an exception if the submission cannot be found' do
      expect {
        SubmissionService.deliver_submission_notification('foo')
      }.to raise_error("Couldn't find Submission with 'id'=foo")
    end

    it 'raises an exception if all of the images have not been processed' do
      submission.update!(receipt_sent_at: Time.now.utc)
      Fabricate(:unprocessed_image, submission: submission)
      expect {
        SubmissionService.deliver_submission_notification(submission.id)
      }.to raise_error('Still processing images.')
    end

    it 'sends an email if the enough time has passed since the initial attempt' do
      allow(Convection.config).to receive(:processing_grace_seconds).and_return(
        600
      )
      allow(Convection.config).to receive(:admin_email_address).and_return(
        'lucille@bluth.com'
      )
      submission.update!(receipt_sent_at: Time.now.utc - 20.minutes)
      Fabricate(:unprocessed_image, submission: submission)
      SubmissionService.deliver_submission_notification(submission.id)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('My Artwork')
    end
  end
end
