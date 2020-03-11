# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'
require_relative '../lib/middleware/jwt_middleware'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Do not display warnings about Ruby 2.7 keyword arguments.
Warning[:deprecated] = false

module Convection
  class Application < Rails::Application # -- all .rb files in that directory are automatically loaded. # Application configuration should go into files in config/initializers # Settings in config/environments/* take precedence over those specified here.
    config.paths.add 'app', glob: '**/*.rb'

    config.eager_load_paths +=
      %W[
        #{config.root}/lib
        #{Rails.root.join('app', 'events')}
        #{Rails.root.join('app', 'services')}
        #{Rails.root.join('app', 'graphql')}
        #{Rails.root.join('app', 'controllers', 'concerns')}
        #{Rails.root.join('app', 'models', 'concerns')}
      ]

    # include JWT middleware
    config.middleware.use ::JwtMiddleware

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post put options]
      end
    end
  end
end
