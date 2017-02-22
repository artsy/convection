class ApplicationMailer < ActionMailer::Base
  default from: 'Artsy <support@artsy.net>'
  layout 'mailer'

  protected

  def smtpapi(opts = {})
    headers['X-SMTPAPI'] = opts.to_json
  end
end
