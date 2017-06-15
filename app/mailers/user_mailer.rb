class UserMailer < ApplicationMailer
  helper :url, :submissions

  def submission_receipt(submission:, user:, user_detail:, artist:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @artist = artist

    smtpapi category: ['submission_receipt'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: 'Submission Receipt', bcc: Convection.config.admin_email_address
  end

  def first_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @utm_params = utm_params(source: 'drip-consignment-reminder-e01', campaign: 'consignment-complete')

    smtpapi category: ['first_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: "You're Almost Done"
  end

  def second_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @utm_params = utm_params(source: 'drip-consignment-reminder-e02', campaign: 'consignment-complete')

    smtpapi category: ['second_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: "You're Almost Done"
  end

  def third_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @utm_params = utm_params(source: 'drip-consignment-reminder-e03', campaign: 'consignment-complete')

    smtpapi category: ['third_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: 'Last chance to complete your consignment'
  end
end
