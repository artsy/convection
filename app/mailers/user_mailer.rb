# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :url, :submissions, :offers

  def submission_receipt(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def first_upload_reminder(submission:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def second_upload_reminder(submission:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def submission_approved(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def artist_submission_rejected(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def fake_submission_rejected(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def nsv_bsv_submission_rejected(submission:, artist:, logged_in:)
    @submission = submission
    @artist = artist
    @logged_in = logged_in

    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "nsv-bsv-rejected"
      )

    smtpapi category: %w[nsv_bsv_submission_rejected],
            unique_args: {
              submission_id: submission.id
            }
    title = submission.title || "Unknown"
    artist_name = artist&.name
    subject = "Update on \"#{title}\" #{artist_name ? "by #{artist_name}" : ""}"
    mail(to: submission.email, subject: subject)
  end

  def non_target_supply_artist_rejected(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def other_submission_rejected(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def offer(offer:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: offer&.submission&.id)
  end

  private

  def warn_submissions_suspended(name:, submission_id:)
    Rails.logger.warn "[Consignments suspended] Declining to deliver user email `#{name}` for Submission #{submission_id || "<unknown>"}"
  end
end
