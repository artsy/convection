module Convection
  mattr_accessor :config
end

Convection.config = OpenStruct.new(
  authentication_token: ENV['AUTHENTICATION_TOKEN'] || 'replace-me',
  contact_phone_number: ENV['CONTACT_PHONE_NUMBER'] || '+1 (646) 712-8154',
  gravity_api_url: ENV['GRAVITY_API_URL'] || 'https://stagingapi.artsy.net/api',
  gravity_xapp_token: ENV['GRAVITY_XAPP_TOKEN'] || 'replace-me',
  sidekiq_username: ENV['SIDEKIQ_USERNAME'] || 'admin',
  sidekiq_password: ENV['SIDEKIQ_PASSWORD'] || 'replace-me',
  smtp_address: ENV['SMTP_ADDRESS'],
  smtp_domain: 'artsy.net',
  smtp_password: ENV['SMTP_PASSWORD'],
  smtp_port: ENV['SMTP_PORT'],
  smtp_user: ENV['SMTP_USER']
)
