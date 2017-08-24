class PartnerMailer < ApplicationMailer
  helper :submissions

  def submission_batch(submissions:, partner_name:)
    @submissions = submissions
    smtpapi category: ['submission_batch'], unique_args: {
      partner_name: partner_name
    }
    # TODO: to will go to all of the partner emails... separately? or together?
    mail to: Convection.config.debug_email_address, subject: "Artsy Submission Batch for: #{partner_name}"
  end
end
