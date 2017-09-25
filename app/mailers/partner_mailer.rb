class PartnerMailer < ApplicationMailer
  helper :url, :submissions

  def submission_digest(submissions:, partner_name:)
    @submissions = submissions
    smtpapi category: ['submission_digest'], unique_args: {
      partner_name: partner_name
    }
    # TODO: to will go to all of the partner emails... separately? or together?
    mail to: Convection.config.debug_email_address, subject: "Artsy Submission Digest for: #{partner_name}"
  end
end
