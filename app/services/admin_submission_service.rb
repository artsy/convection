class AdminSubmissionService
  class << self
    def update_submission(submission, params, current_user)
      submission.assign_attributes(params)
      update_submission_state(submission, current_user) if submission.state_changed?
      submission.save!
    end

    def update_submission_state(submission, current_user)
      if submission.approved?
        submission.update_attributes!(approved_by: current_user, approved_at: Time.now.utc)
        delay.deliver_approval_notification(submission.id)
      elsif submission.rejected?
        submission.update_attributes!(rejected_by: current_user, rejected_at: Time.now.utc)
        delay.deliver_rejection_notification(submission.id)
      end
    end

    def deliver_approval_notification(submission_id)
      submission = Submission.find(submission_id)
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_approved(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end

    def deliver_rejection_notification(submission_id)
      submission = Submission.find(submission_id)
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_rejected(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end
  end
end
