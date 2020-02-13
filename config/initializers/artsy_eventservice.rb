# frozen_string_literal: true

Artsy::EventService.configure do |config|
  config.app_name = 'artsy-convection'
  config.event_stream_enabled = true
  config.rabbitmq_url = ENV['RABBITMQ_URL']
  config.tls = true
  config.tls_ca_certificate = Base64.decode64(ENV['RABBITMQ_CA_CERT'] || '')
  config.tls_cert = Base64.decode64(ENV['RABBITMQ_CLIENT_CERT'] || '')
  config.tls_key = Base64.decode64(ENV['RABBITMQ_CLIENT_KEY'] || '')
  config.verify_peer = ENV['RABBITMQ_NO_VERIFY_PEER'] != 'true'
end
