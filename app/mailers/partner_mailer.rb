class PartnerMailer < ApplicationMailer
  helper :url, :submissions

  def submission_digest(submissions:, partner:)
    @submissions = submissions
    @partner_type = partner.type
    @utm_params = utm_params(source: 'consignment-partner-digest', campaign: 'consignment-complete')
    smtpapi category: ['submission_digest'], unique_args: {
      partner_name: partner.name
    }

    current_date = Time.now.utc.strftime('%B %-d')
    # TODO: to will go to all of the partner emails... separately? or together?
    mail(
      to: Convection.config.debug_email_address,
      subject: "New Artsy Consignments #{current_date}: #{@submissions.count} works"
    ) do |format|
      format.html { render layout: 'mailer_no_footer' }
    end
  end
end
