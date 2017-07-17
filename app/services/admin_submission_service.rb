class AdminSubmissionService
  class << self
    def update_submission(submission, params, current_user)
      submission.assign_attributes(params)
      approved = submission.state_changed? && submission.state == 'approved'
      rejected = submission.state_changed? && submission.state == 'rejected'
      submission.save!
      if approved
        submission.update_attributes!(approved_by: current_user)
        delay.deliver_approval_notification(submission.id)
      elsif rejected
        submission.update_attributes!(rejected_by: current_user)
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
