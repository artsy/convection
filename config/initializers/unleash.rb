module Convection
  mattr_accessor :unleash
end

Convection.unleash =
  Unleash::Client.new(
    url: Convection.config[:unleash_url],
    app_name: 'convection',
    custom_http_headers: {
      'Authorization': Convection.config[:unleash_token]
    },
    disable_client: Convection.config[:unleash_url].blank?,
    instance_id: Socket.gethostname,
    logger: Rails.logger,
    environment: Rails.env,
    metrics_interval: 60,
    refresh_interval: 60
  )
