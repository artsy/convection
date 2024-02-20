# frozen_string_literal: true

ArtsyAuth.configure do |config|
  config.artsy_api_url = Convection.config.gravity_url
  config.callback_url = "/"
  config.application_id = Convection.config.gravity_app_id
  config.application_secret = Convection.config.gravity_app_secret
end
