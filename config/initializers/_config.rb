# frozen_string_literal: true

module Convection
  mattr_accessor :config
end

Convection.config =
  OpenStruct.new(
    access_token: ENV["ACCESS_TOKEN"] || "replace-me",
    admin_names: (ENV["ADMIN_NAMES"] || "Alice Betty Cindy").split,
    admin_email_address: ENV["ADMIN_EMAIL_ADDRESS"] || "sell@artsy.net",
    artsy_url: ENV["ARTSY_URL"] || "https://staging.artsy.net",
    artsy_cms_url: ENV["ARTSY_CMS_URL"] || "https://cms-staging.artsy.net",
    auction_offer_form_url: ENV["AUCTION_OFFER_FORM_URL"] || "https://foo.com",
    aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID", nil),
    aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", nil),
    aws_upload_bucket: ENV.fetch("AWS_UPLOAD_BUCKET", nil),
    offer_response_form_url:
      ENV["OFFER_RESPONSE_FORM_URL"] || "https://foo.com",
    bcc_email_address:
      ENV["BCC_EMAIL_ADDRESS"] || "consignments-archive@artsymail.com",
    cloudfront_url: ENV["CLOUDFRONT_URL"],
    consignment_communication_name:
      ENV["CONSIGNMENT_COMMUNICATION_NAME"] || "Consignment Submissions",
    contact_email_address: ENV["CONTACT_EMAIL"] || "specialist@artsy.net",
    contact_phone_number: ENV["CONTACT_PHONE_NUMBER"] || "+1 (646) 712-8154",
    convection_url:
      ENV["CONVECTION_URL"] || "https://convection-staging.artsy.net",
    datadog_trace_agent_hostname: ENV["DATADOG_TRACE_AGENT_HOSTNAME"],
    datadog_debug: ENV["DATADOG_DEBUG"] == "true",
    debug_email_address: ENV["DEBUG_EMAIL_ADDRESS"] || "sarah@artsymail.com",
    enable_myc_artwork_updated_email: ENV["ENABLE_MYC_ARTWORK_UPDATED_EMAIL"] == "true",
    forque_url: ENV["FORQUE_URL"] || "https://tools-staging.artsy.net",
    gemini_account_key: ENV["GEMINI_ACCOUNT_KEY"] || "convection-staging",
    gemini_app: ENV["GEMINI_APP"] || "https://media.artsy.net",
    metaphysics_api_url:
      "#{ENV["METAPHYSICS_URL"] || "https://metaphysics-staging.artsy.net"}/v2",
    gravity_api_url:
      "#{ENV["GRAVITY_URL"] || "https://stagingapi.artsy.net"}/api",
    gravity_app_id: ENV["GRAVITY_APP_ID"] || "replace-me",
    gravity_app_secret: ENV["GRAVITY_APP_SECRET"] || "replace-me",
    gravity_xapp_token: ENV["GRAVITY_XAPP_TOKEN"] || "replace-me",
    gravity_url: ENV["GRAVITY_URL"] || "https://stagingapi.artsy.net",
    jwt_secret: ENV["JWT_SECRET"] || "replace-me",
    processing_grace_seconds: (ENV["PROCESSING_GRACE_SECONDS"] || 600).to_i,
    rabbitmq_ca_cert: (Base64.decode64(ENV["RABBITMQ_CA_CERT"]) if ENV["RABBITMQ_CA_CERT"]),
    rabbitmq_client_cert: (Base64.decode64(ENV["RABBITMQ_CLIENT_CERT"]) if ENV["RABBITMQ_CLIENT_CERT"]),
    rabbitmq_client_key: (Base64.decode64(ENV["RABBITMQ_CLIENT_KEY"]) if ENV["RABBITMQ_CLIENT_KEY"]),
    rabbitmq_consume_url: ENV["RABBITMQ_CONSUME_URL"] || ENV["RABBITMQ_URL"],
    rabbitmq_verify_peer: ENV["RABBITMQ_NO_VERIFY_PEER"] != "true",
    salesforce_client_id: ENV["SALESFORCE_CLIENT_ID"],
    salesforce_client_secret: ENV["SALESFORCE_CLIENT_SECRET"],
    salesforce_host: ENV["SALESFORCE_HOST"],
    salesforce_password: ENV["SALESFORCE_PASSWORD"],
    salesforce_security_token: ENV["SALESFORCE_SECURITY_TOKEN"],
    salesforce_username: ENV["SALESFORCE_USERNAME"],
    sentry_dsn: ENV["SENTRY_DSN"],
    sidekiq_username: ENV["SIDEKIQ_USERNAME"] || "admin",
    sidekiq_password: ENV["SIDEKIQ_PASSWORD"] || "replace-me",
    smtp_address: ENV["SMTP_ADDRESS"],
    smtp_domain: "artsy.net",
    smtp_password: ENV["SMTP_PASSWORD"],
    smtp_port: ENV["SMTP_PORT"],
    smtp_user: ENV["SMTP_USER"],
    sneakers_auto_recover: ENV["SNEAKERS_AUTO_RECOVER"] == "true",
    second_reminder_days_after: (ENV["SECOND_REMINDER_DAYS_AFTER"] || 7).to_i,
    rejection_email_minutes_after:
      (ENV["REJECTION_EMAIL_MINUTES_AFTER"] || 60).to_i,
    vibrations_url:
      ENV["VIBRATIONS_URL"] || "https://admin-partners-staging.artsy.net",
    unleash_url: ENV["UNLEASH_URL"],
    unleash_token: ENV["UNLEASH_TOKEN"],
    send_new_receipt_email: ENV["SEND_NEW_RECEIPT_EMAIL"] == "true"
  )
