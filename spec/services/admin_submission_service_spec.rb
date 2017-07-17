require 'rails_helper'
require 'support/gravity_helper'

describe AdminSubmissionService do
  let(:submission) do
    Fabricate(:submission, artist_id: 'artistid', user_id: 'userid', title: 'My Artwork')
  end

  before do
    stub_gravity_root
    stub_gravity_user
    stub_gravity_user_detail(email: 'michael@bluth.com')
    stub_gravity_artist
  end

  context 'update_submission' do
    it 'sends no emails if the state is not being changed' do
      AdminSubmissionService.update_submission(submission, { title: 'Updated Artwork Title', state: 'draft' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.title).to eq 'Updated Artwork Title'
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end

    it 'sends no emails if the state is not being changed to approved or rejected' do
      AdminSubmissionService.update_submission(submission, { state: 'submitted' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end

    it 'sends an approval notification if the submission state is changed to approved' do
      AdminSubmissionService.update_submission(submission, { state: 'approved' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('Your submission has been approved!')
      expect(submission.state).to eq 'approved'
      expect(submission.approved_by).to eq 'userid'
      expect(submission.approved_at).to_not be_nil
      expect(submission.rejected_by).to be_nil
      expect(submission.rejected_at).to be_nil
    end

    it 'sends a rejection notification if the submission state is changed to rejected' do
      AdminSubmissionService.update_submission(submission, { state: 'rejected' }, 'userid')
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 1
      expect(emails.first.html_part.body).to include('So sorry your submission has been rejected.')
      expect(submission.state).to eq 'rejected'
      expect(submission.rejected_by).to eq 'userid'
      expect(submission.rejected_at).to_not be_nil
      expect(submission.approved_by).to be_nil
      expect(submission.approved_at).to be_nil
    end
  end

  context 'deliver_approval_notification' do
    it 'raises an exception if the submission cannot be found' do
      expect do
        AdminSubmissionService.deliver_approval_notification('foo')
      end.to raise_error("Couldn't find Submission with 'id'=foo")
    end
  end

  context 'deliver_rejection_notification' do
    it 'raises an exception if the submission cannot be found' do
      expect do
        AdminSubmissionService.deliver_rejection_notification('foo')
      end.to raise_error("Couldn't find Submission with 'id'=foo")
    end
  end
end
