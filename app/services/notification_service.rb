class NotificationService
  class << self
    def post_submission_event(submission_id, action)
      submission = Submission.find(submission_id)
      # post notification
      event = SubmissionEvent.new(action: action, model: submission)
      Artsy::EventService.post_event(topic: SubmissionEvent::TOPIC, event: event)
    end

    def deliver_upload_reminder(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at || submission.images.count.positive?
      user = Gravity.client.user(id: submission.user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      email_args = {
        submission: submission,
        user: user,
        user_detail: user_detail
      }

      if submission.reminders_sent_count == 1
        UserMailer.second_upload_reminder(email_args).deliver_now
      elsif submission.reminders_sent_count == 2
        UserMailer.third_upload_reminder(email_args).deliver_now
      else
        UserMailer.first_upload_reminder(email_args).deliver_now
      end
      submission.increment!(:reminders_sent_count)
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
