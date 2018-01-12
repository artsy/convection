Raven.configure do |config|
  config.dsn = Convection.config.sentry_dsn if Convection.config.sentry_dsn
  config.processors -= [Raven::Processor::PostData]
end
