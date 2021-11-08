# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  helper :submissions

  def submission(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist

    smtpapi category: %w[submission],
            unique_args: {
              submission_id: submission.id
            }
    mail(
      to: Convection.config.admin_email_address,
      subject: "Submission ##{@submission.id}"
    ) { |format| format.html { render layout: 'mailer_no_footer' } }
  end
end
