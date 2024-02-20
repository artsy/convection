# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include UtmParamsHelper
  default from: "Artsy <sell@artsy.net>"
  default bcc: Convection.config.bcc_email_address
  layout "mailer"

  protected

  def smtpapi(opts = {})
    headers["X-SMTPAPI"] = opts.to_json
  end
end
