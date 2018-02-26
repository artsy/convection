class ApplicationMailer < ActionMailer::Base
  default from: 'Artsy <consign@artsy.net>'
  default bcc: Convection.config.bcc_email_address
  layout 'mailer'

  protected

  def smtpapi(opts = {})
    headers['X-SMTPAPI'] = opts.to_json
  end

  def utm_params(source:, campaign:)
    {
      utm_campaign: campaign,
      utm_medium: 'email',
      utm_source: source
    }
  end
end
