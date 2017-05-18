class AdminMailer < ApplicationMailer
  def submission(submission:, user:, user_detail:, artist:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @artist = artist

    smtpapi category: ['submission'], unique_args: {
      submission_id: submission.id
    }
    mail to: Convection.config.admin_email_address, bcc: [], subject: 'Submission'
  end
end
