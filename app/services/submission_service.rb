class SubmissionService
  ParamError = Class.new(StandardError)

  class << self
    def update_submission(submission, params)
      submission.assign_attributes(params)
      submitting = submission.state_changed? && submission.state == 'submitted'
      raise ParamError, 'Missing fields for submission.' if submitting && !submission.can_submit?
      submission.save!
      notify(submission) if submitting
    end

    def notify(submission)
      return if submission.receipt_sent_at
      delay.deliver_submission_notification(submission.id)
      if submission.assets.count > 0
        delay.deliver_submission_receipt(submission.id)
        submission.update_attributes!(receipt_sent_at: Time.now.utc)
      else
        return if reminders_sent_count >= 2
        delay.deliver_submission_reminder(submission.id)
        submission.update_attributes!(reminders_sent_count: submission.reminders_sent_count + 1)
      end
    end

    def deliver_submission_reminder(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at || submission.assets.count > 0
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      if reminders_sent_count > 0
        UserMailer.first_submission_reminder(
          submission: submission,
          user: user,
          user_detail: user_detail
        ).deliver_now
      else
        UserMailer.second_submission_reminder(
          submission: submission,
          user: user,
          user_detail: user_detail
        ).deliver_now
      end
    end

    def deliver_submission_receipt(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_receipt(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end

    def deliver_submission_notification(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      AdminMailer.submission(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      ).deliver_now
    end
  end
end
