# frozen_string_literal: true

class SubmissionService
  class ParamError < StandardError; end
  class SubmissionError < StandardError; end

  class << self
    def create_submission(submission_params, gravity_user_id)
      user = User.find_or_create_by!(gravity_user_id: gravity_user_id)
      create_params = submission_params.merge(user_id: user.id)
      submission = Submission.create!(create_params)
      UserService.delay.update_email(user.id)
      submission
    rescue ActiveRecord::RecordInvalid => e
      raise SubmissionError, e.message
    end

    def update_submission(submission, params, current_user: nil)
      user = User.find_or_create_by!(gravity_user_id: params[:user_id])
      create_params = params.merge(user_id: user.id)
      submission.assign_attributes(create_params)
      if submission.state_changed?
        update_submission_state(submission, current_user)
      end
      submission.save!
    end

    def update_submission_state(submission, current_user)
      case submission.state
      when 'submitted'
        submit!(submission)
      when 'approved'
        approve!(submission, current_user)
      when 'published'
        publish!(submission, current_user)
      when 'rejected'
        reject!(submission, current_user)
      when 'closed'
        close!(submission)
      end
    end

    def undo_approval(submission)
      if submission.offers.count.positive?
        raise SubmissionError,
              'Undoing approval of a submission with offers is not allowed!'
      end

      return_to_submitted_state(submission)
      submission.partner_submissions.each(&:destroy)
    end

    def undo_publish(submission)
      if submission.offers.count.positive?
        raise SubmissionError,
              'Undoing publish of a submission with offers is not allowed!'
      end

      return_to_submitted_state(submission)
      submission.partner_submissions.each(&:destroy)
    end

    def undo_rejection(submission)
      return_to_submitted_state(submission)
    end

    def undo_close(submission)
      return_to_submitted_state(submission)
    end

    def return_to_submitted_state(submission)
      submission.update!(
        state: 'submitted',
        approved_at: nil,
        approved_by: nil,
        rejected_at: nil,
        rejected_by: nil,
        published_at: nil
      )
    end

    def submit!(submission)
      unless submission.can_submit?
        raise ParamError, 'Missing fields for submission.'
      end

      notify_admin(submission.id)
      notify_user(submission.id)
      return if submission.images.count.positive?

      delay_until(Convection.config.second_reminder_days_after.days.from_now)
        .notify_user(submission.id)
    end

    def approve!(submission, current_user)
      submission.update!(approved_by: current_user, approved_at: Time.now.utc)
      NotificationService.delay.post_submission_event(
        submission.id,
        SubmissionEvent::APPROVED
      )
    end

    def publish!(submission, current_user)
      submission.update!(
        approved_by: submission.approved_by || current_user,
        approved_at: submission.approved_at || Time.now.utc,
        published_at: Time.now.utc
      )

      NotificationService.delay.post_submission_event(
        submission.id,
        SubmissionEvent::PUBLISHED
      )

      delay.deliver_approval_notification(submission.id)
      PartnerSubmissionService.delay.generate_for_all_partners(submission.id)
    end

    def reject!(submission, current_user)
      submission.update!(rejected_by: current_user, rejected_at: Time.now.utc)
      delay.deliver_rejection_notification(submission.id)
    end

    def close!(submission)
      # noop
    end

    def notify_admin(submission_id)
      submission = Submission.find(submission_id)
      return if submission.admin_receipt_sent_at

      delay.deliver_submission_notification(submission.id)
      NotificationService.delay.post_submission_event(
        submission_id,
        SubmissionEvent::SUBMITTED
      )
      submission.update!(admin_receipt_sent_at: Time.now.utc)
    end

    def notify_user(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at

      if submission.images.count.positive?
        delay.deliver_submission_receipt(submission.id)
        submission.update!(receipt_sent_at: Time.now.utc)
      else
        return if submission.reminders_sent_count >= 2

        delay.deliver_upload_reminder(submission.id)
      end
    end

    def deliver_upload_reminder(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at || submission.images.count.positive?

      user = Gravity.client.user(id: submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      email_args = {
        submission: submission, user: user, user_detail: user_detail
      }

      if submission.reminders_sent_count == 1
        UserMailer.second_upload_reminder(email_args).deliver_now
      else
        UserMailer.first_upload_reminder(email_args).deliver_now
      end
      submission.increment!(:reminders_sent_count)
    end

    def deliver_submission_receipt(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?

      user = Gravity.client.user(id: submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_receipt(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      )
        .deliver_now
    end

    def deliver_submission_notification(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?

      user = Gravity.client.user(id: submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      AdminMailer.submission(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      )
        .deliver_now
    end

    def deliver_approval_notification(submission_id)
      submission = Submission.find(submission_id)
      user = Gravity.client.user(id: submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_approved(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      )
        .deliver_now
    end

    def deliver_rejection_notification(submission_id)
      submission = Submission.find(submission_id)
      user = Gravity.client.user(id: submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_rejected(
        submission: submission,
        user: user,
        user_detail: user_detail,
        artist: artist
      )
        .deliver_now
    end
  end
end
