class UserMailer < ApplicationMailer
  def submission_receipt(submission:, user:, user_detail:, artist:)
    @submission = submission
    @user = user
    @user_detail = user_detail
    @artist = artist

    smtpapi category: ['submission_receipt'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: 'Submission Receipt'
  end

  def first_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail

    smtpapi category: ['first_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: "You're Almost Done"
  end

  def second_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail

    smtpapi category: ['second_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: "You're Almost Done"
  end

  def third_upload_reminder(submission:, user:, user_detail:)
    @submission = submission
    @user = user
    @user_detail = user_detail

    smtpapi category: ['third_upload_reminder'], unique_args: {
      submission_id: submission.id
    }
    mail to: user_detail.email, subject: 'Submission Receipt'
  end
end
