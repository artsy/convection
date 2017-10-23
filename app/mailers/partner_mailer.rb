class PartnerMailer < ApplicationMailer
  helper :url, :submissions

  def submission_digest(submissions:, partner_name:, partner_type:, email:)
    @submissions = submissions
    @partner_type = partner_type
    @utm_params = utm_params(source: 'consignment-partner-digest', campaign: 'consignment-complete')
    smtpapi category: ['submission_digest'], unique_args: {
      partner_name: partner_name
    }

    current_date = Time.now.utc.strftime('%B %-d')
    mail(
      to: email,
      from: Convection.config.admin_email_address,
      subject: "New Artsy Consignments #{current_date}: #{@submissions.count} works"
    ) do |format|
      format.html { render layout: 'mailer_no_footer' }
    end
  end
end
