# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  helper :submissions, :url

  def submission(submission:, user:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def submission_approved(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def submission_resubmitted(submission:, artist:)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def artwork_updated(submission:, artwork_data:, changes: nil, image_added: nil)
    warn_submissions_suspended(name: __method__, submission_id: submission&.id)
  end

  def warn_submissions_suspended(name:, submission_id:)
    Rails.logger.warn "[Consignments suspended] Declining to deliver admin email `#{name}` for Submission #{submission_id || "<unknown>"}"
  end
end
