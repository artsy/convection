class SubmissionService
  ParamError = Class.new(StandardError)

  class << self
    def update_submission(submission, params)
      submission.assign_attributes(params)
      submitting = submission.state_changed? && submission.state == 'submitted'
      raise ParamError, 'Missing fields for submission.' if submitting && !submission.can_submit?
      submission.save!
      return unless submitting
      notify_admin(submission.id)
      notify_user(submission.id)
      delay_until(1.day.from_now).notify_user(submission.id)
    end

    def notify_admin(submission_id)
      submission = Submission.find(submission_id)
      return if submission.admin_receipt_sent_at
      delay.deliver_submission_notification(submission.id)
      submission.update_attributes!(admin_receipt_sent_at: Time.now.utc)
    end

    def notify_user(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at
      if submission.images.count.positive?
        delay.deliver_submission_receipt(submission.id)
        submission.update_attributes!(receipt_sent_at: Time.now.utc)
      else
        return if submission.reminders_sent_count >= 2
        delay.deliver_upload_reminder(submission.id)
      end
    end

    def deliver_upload_reminder(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at || submission.images.count.positive?
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      if submission.reminders_sent_count.positive?
        UserMailer.second_upload_reminder(
          submission: submission,
          user: user,
          user_detail: user_detail
        ).deliver_now
      else
        UserMailer.first_upload_reminder(
          submission: submission,
          user: user,
          user_detail: user_detail
        ).deliver_now
      end
      submission.increment!(:reminders_sent_count) # rubocop:disable Rails/SkipsModelValidations
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
