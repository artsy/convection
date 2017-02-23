class AdminMailer < ApplicationMailer
  ADMIN_EMAILS = ['specialist@artsy.net'].freeze

  def submission(submission:, user:, user_detail:, artist:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @artist = artist

    smtpapi category: ['submission'], unique_args: {
      submission_id: submission.id
    }
    mail to: ADMIN_EMAILS, bcc: [], subject: 'Submission'
  end
end
