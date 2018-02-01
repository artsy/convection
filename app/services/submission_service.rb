class SubmissionService
  ParamError = Class.new(StandardError)

  class << self
    def create_submission(submission_params, current_user)
      create_params = submission_params.merge(user_id: current_user)
      submission = Submission.create!(create_params)
      delay.update_user_email(submission.id)
      submission
    end

    def update_submission(submission, params, current_user = nil)
      submission.assign_attributes(params)
      update_submission_state(submission, current_user) if submission.state_changed?
      submission.save!
    end

    def update_submission_state(submission, current_user)
      case submission.state
      when 'submitted' then submit!(submission)
      when 'approved' then approve!(submission, current_user)
      when 'rejected' then reject!(submission, current_user)
      end
    end

    def update_user_email(submission_id)
      submission = Submission.find(submission_id)
      email = Gravity.client.user_detail(id: submission.user_id).email
      raise 'User lacks email.' if email.blank?
      submission.update_attributes!(user_email: email)
    end

    def submit!(submission)
      raise ParamError, 'Missing fields for submission.' unless submission.can_submit?
      notify_admin(submission.id)
      notify_user(submission.id)
      return if submission.images.count.positive?
      delay_until(Convection.config.second_reminder_days_after.days.from_now).notify_user(submission.id)
      delay_until(Convection.config.third_reminder_days_after.days.from_now).notify_user(submission.id)
    end

    def approve!(submission, current_user)
      submission.update_attributes!(approved_by: current_user, approved_at: Time.now.utc)
      delay.deliver_approval_notification(submission.id)
      PartnerSubmissionService.delay.generate_for_all_partners(submission.id)
    end

    def reject!(submission, current_user)
      submission.update_attributes!(rejected_by: current_user, rejected_at: Time.now.utc)
      delay.deliver_rejection_notification(submission.id)
    end

    def notify_admin(submission_id)
      submission = Submission.find(submission_id)
      return if submission.admin_receipt_sent_at
      delay.deliver_submission_notification(submission.id)
      NotificationService.delay.post_submission_event(submission_id, SubmissionEvent::SUBMITTED)
      submission.update_attributes!(admin_receipt_sent_at: Time.now.utc)
    end

    def notify_user(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at
      if submission.images.count.positive?
        delay.deliver_submission_receipt(submission.id)
        submission.update_attributes!(receipt_sent_at: Time.now.utc)
      else
        return if submission.reminders_sent_count >= 3
        delay.deliver_upload_reminder(submission.id)
      end
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
