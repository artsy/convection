module Convection
  mattr_accessor :config
end

Convection.config = OpenStruct.new(
  access_token: ENV['ACCESS_TOKEN'] || 'replace-me',
  admin_email_address: ENV['ADMIN_EMAIL_ADDRESS'] || 'consign@artsy.net',
  artsy_url: ENV['ARTSY_URL'] || 'https://staging.artsy.net',
  auction_offer_form_url: ENV['AUCTION_OFFER_FORM_URL'] || 'https://foo.com',
  cloudfront_url: ENV['CLOUDFRONT_URL'],
  consignment_communication_name: ENV['CONSIGNMENT_COMMUNICATION_NAME'] || 'Consignment Submissions',
  contact_email_address: ENV['CONTACT_EMAIL'] || 'specialist@artsy.net',
  contact_phone_number: ENV['CONTACT_PHONE_NUMBER'] || '+1 (646) 712-8154',
  convection_url: ENV['CONVECTION_URL'] || 'https://convection-staging.artsy.net',
  debug_email_address: ENV['DEBUG_EMAIL_ADDRESS'] || 'sarah@artsymail.com',
  gemini_account_key: ENV['GEMINI_ACCOUNT_KEY'] || 'convection-staging',
  gemini_app: ENV['GEMINI_APP'] || 'https://media.artsy.net',
  gemini_s3_key: ENV['GEMINI_S3_KEY'] || 'replace-me',
  gravity_api_url: "#{ENV['GRAVITY_URL'] || 'https://stagingapi.artsy.net'}/api",
  gravity_app_id: ENV['GRAVITY_APP_ID'] || 'replace-me',
  gravity_app_secret: ENV['GRAVITY_APP_SECRET'] || 'replace-me',
  gravity_xapp_token: ENV['GRAVITY_XAPP_TOKEN'] || 'replace-me',
  gravity_url: ENV['GRAVITY_URL'] || 'https://stagingapi.artsy.net',
  jwt_secret: ENV['JWT_SECRET'] || 'replace-me',
  processing_grace_seconds: (ENV['PROCESSING_GRACE_SECONDS'] || 600).to_i,
  second_reminder_days_after: (ENV['SECOND_REMINDER_DAYS_AFTER'] || 1).to_i,
  sidekiq_username: ENV['SIDEKIQ_USERNAME'] || 'admin',
  sidekiq_password: ENV['SIDEKIQ_PASSWORD'] || 'replace-me',
  smtp_address: ENV['SMTP_ADDRESS'],
  smtp_domain: 'artsy.net',
  smtp_password: ENV['SMTP_PASSWORD'],
  smtp_port: ENV['SMTP_PORT'],
  smtp_user: ENV['SMTP_USER'],
  third_reminder_days_after: (ENV['THIRD_REMINDER_DAYS_AFTER'] || 7).to_i,
  vibrations_url: ENV['VIBRATIONS_URL'] || 'https://admin-partners-staging.artsy.net'
)
