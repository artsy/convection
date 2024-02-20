# frozen_string_literal: true

Sidekiq::Extensions.enable_delay!

if Rails.env.development?
  redis_config = {url: "redis://localhost:6379/#{ENV.fetch("REDIS_DB", 0)}"}

  Sidekiq.configure_server { |config| config.redis = redis_config }

  Sidekiq.configure_client { |config| config.redis = redis_config }
end
