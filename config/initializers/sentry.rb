# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Convection.config.sentry_dsn if Convection.config.sentry_dsn
end
