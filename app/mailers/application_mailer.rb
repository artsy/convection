class ApplicationMailer < ActionMailer::Base
  default from: 'Artsy <support@artsy.net>'
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
