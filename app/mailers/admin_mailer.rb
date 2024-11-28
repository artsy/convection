# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  helper :submissions, :url

  def submission(submission:, user:, artist:)
    @submission = submission
    @user = user
    @artist = artist
    @utm_params =
      utm_params(
        source: "sendgrid",
        campaign: "sell",
        term: "cx",
        content: "received"
      )

    smtpapi category: %w[submission],
            unique_args: {
              submission_id: submission.id
            }
    mail(
      to: Convection.config.admin_email_address,
      subject: "Submission ##{@submission.id}"
    ) { |format| format.html { render layout: "mailer_no_footer" } }
  end

  def submission_approved(submission:, artist:)
    @submission = submission
    @artist = artist
    @user = submission.user

    assigned_admin = AdminUser.find_by(gravity_user_id: submission.assigned_to)

    smtpapi category: %w[submission],
            unique_args: {
              submission_id: submission.id
            }

    mail(
      to: assigned_admin.email,
      subject: "Submission ##{@submission.id} approved"
    ) { |format| format.html { render layout: "mailer_no_footer" } }
  end

  def submission_resubmitted(submission:, artist:)
    @submission = submission
    @artist = artist
    @user = submission.user

    assigned_admin = AdminUser.find_by(gravity_user_id: submission.assigned_to)

    smtpapi category: %w[submission],
            unique_args: {
              submission_id: submission.id
            }

    mail(
      to: assigned_admin.email,
      subject: "Submission ##{@submission.id} resubmitted"
    ) { |format| format.html { render layout: "mailer_no_footer" } }
  end

  def artwork_updated(submission:, artwork_data:, changes: nil, image_added: nil)
    assigned_admin = AdminUser.find_by(gravity_user_id: submission.assigned_to)

    @submission = submission
    @user_id = submission.user.gravity_user_id
    @user_email = submission.user.email
    @artwork_id = artwork_data[:id]
    @changes = changes
    @image_added = image_added

    smtpapi category: %w[submission],
            unique_args: {
              submission_id: submission.id
            }

    mail(
      to: assigned_admin.email,
      subject: "Submission ##{@submission.id} artwork updated by a user"
    ) { |format| format.html { render layout: "mailer_no_footer" } }
  end
end
