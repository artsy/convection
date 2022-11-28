# frozen_string_literal: true

class SubmissionService
  extend GraphqlHelper

  class ParamError < StandardError
  end

  class SubmissionError < StandardError
  end

  class << self
    def create_submission(
      submission_params,
      gravity_user_id,
      is_convection: true,
      current_user: nil
    )
      submission_params[:edition_size] =
        submission_params.delete(:edition_size_formatted) if submission_params[
        :edition_size_formatted
      ]

      create_params = submission_params.clone

      if gravity_user_id.present?
        user = User.find_or_create_by(gravity_user_id: gravity_user_id)

        create_params.merge!(user_id: user&.id)
      end

      if AdminUser.exists?(gravity_user_id: current_user)
        create_params.merge!(
          admin: AdminUser.find_by(gravity_user_id: current_user)
        )
      end

      create_params.merge!(source: 'admin') if is_convection

      unless is_convection || submission_params[:state]&.downcase == 'draft'
        create_params.merge!(
          reject_non_target_supply_artist(submission_params[:artist_id])
        )
      end

      submission = Submission.create!(create_params)

      if create_params[:state] == 'rejected'
        delay_until(
          Convection.config.rejection_email_minutes_after.minutes.from_now
        ).deliver_rejection_notification(submission.id)
      end

      submission
    rescue ActiveRecord::RecordInvalid => e
      raise SubmissionError, e.message
    end

    def reject_non_target_supply_artist(artist_id)
      artist = Gravity.client.artist(id: artist_id)._get
      params = {}
      unless artist[:target_supply]
        params = {
          state: 'rejected',
          rejection_reason: 'Not Target Supply',
          rejected_at: Time.now.utc
        }
      end
      params
    end

    def update_submission(
      submission,
      params,
      current_user: nil,
      is_convection: true,
      access_token: nil
    )
      params[:edition_size] = params.delete(:edition_size_formatted) if params[
        :edition_size_formatted
      ]
      if params[:user_id]
        user = User.find_or_create_by!(gravity_user_id: params[:user_id])
        create_params = params.merge(user_id: user.id)
        submission.assign_attributes(create_params)
      else
        submission.assign_attributes(params)
      end

      if submission.state_changed?
        unless is_convection
          submission.assign_attributes(
            reject_non_target_supply_artist(submission.artist_id)
          )
          if !submission.draft? && submission.user && !access_token.nil?
            create_or_update_my_collection_artwork(submission, access_token)
          end
        end

        update_submission_state(submission, current_user)
      end
      submission.save!
    end

    def create_or_update_my_collection_artwork(submission, access_token)
      if !submission.my_collection_artwork_id
        create_my_collection_artwork(submission, access_token)
      elsif submission.source == 'my_collection'
        update_my_collection_artwork(submission, access_token)
      end
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

      SalesforceService.delay.add_artwork(submission.id)
      NotificationService.delay.post_submission_event(
        submission.id,
        SubmissionEvent::APPROVED
      )
    end

    def publish!(submission, current_user)
      SalesforceService.delay.add_artwork(submission.id) unless submission.approved_at

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

      delay_until(5.minutes.from_now).deliver_submission_notification(submission.id)
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
        delay_until(5.minutes.from_now).deliver_submission_receipt(submission.id)
        submission.update!(receipt_sent_at: Time.now.utc)
      else
        return if submission.reminders_sent_count >= 2

        delay_until(5.minutes.from_now).deliver_upload_reminder(submission.id)
      end
    end

    def deliver_upload_reminder(submission_id)
      submission = Submission.find(submission_id)
      return if submission.receipt_sent_at || submission.images.count.positive?

      raise 'User lacks email.' if submission.email.blank?

      email_args = { submission: submission }

      if submission.reminders_sent_count == 1
        UserMailer.second_upload_reminder(**email_args).deliver_now
      else
        UserMailer.first_upload_reminder(**email_args).deliver_now
      end
      submission.increment!(:reminders_sent_count)
    end

    def deliver_submission_receipt(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?

      Rails.logger.warn 'User lacks email.' if submission.email.blank?

      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_receipt(submission: submission, artist: artist)
        .deliver_now
    end

    def deliver_submission_notification(submission_id)
      submission = Submission.find(submission_id)
      raise 'Still processing images.' unless submission.ready?

      user = submission.user
      artist = Gravity.client.artist(id: submission.artist_id)._get

      AdminMailer.submission(submission: submission, user: user, artist: artist)
        .deliver_now
    end

    def deliver_approval_notification(submission_id)
      submission = Submission.find(submission_id)
      artist = Gravity.client.artist(id: submission.artist_id)._get

      UserMailer.submission_approved(submission: submission, artist: artist)
        .deliver_now
    end

    def deliver_rejection_notification(submission_id)
      submission = Submission.find(submission_id)
      artist = Gravity.client.artist(id: submission.artist_id)._get

      rejection_reason_template =
        case submission.rejection_reason
        when 'Fake'
          'fake_submission_rejected'
        when 'Artist Submission'
          'artist_submission_rejected'
        when 'NSV', 'BSV'
          'nsv_bsv_submission_rejected'
        when 'Not Target Supply'
          'non_target_supply_artist_rejected'
        else
          'other_submission_rejected'
        end

      UserMailer.send(
        rejection_reason_template,
        submission: submission,
        artist: artist
      ).deliver_now
    end

    def update_submission_info(artwork, submission)
      submission.assign_attributes(
        title: artwork.title,
        medium: artwork.medium,
        year: artwork.date,
        artist_id: artwork.artists.first.id
      )
      submission.save!
    end

    def add_user_to_submission(submission, gravity_user_id, access_token)
      # add user to submission when user is present and ENV for the feature allows
      if gravity_user_id.present? && Convection.config.send_new_receipt_email
        user = User.find_or_create_by(gravity_user_id: gravity_user_id)
        submission.update!(user_id: user&.id)

        # create artwork in user's collection
        if !access_token.nil? && !submission.my_collection_artwork_id
          create_my_collection_artwork(submission, access_token)
        end
      end

      submission
    end
  end
end
