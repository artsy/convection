# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require_relative "../lib/jwt_middleware"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Do not display warnings about Ruby 2.7 keyword arguments.
Warning[:deprecated] = false

module Convection
  # -- all .rb files in that directory are automatically loaded. # Application configuration should go into files in config/initializers # Settings in config/environments/* take precedence over those specified here.
  class Application < Rails::Application
    config.paths.add "app", glob: "**/*.rb"
    config.load_defaults 6.0

    config.eager_load_paths +=
      %W[
        #{config.root}/lib
        #{Rails.root.join("app", "events")}
        #{Rails.root.join("app", "presenters")}
        #{Rails.root.join("app", "services")}
        #{Rails.root.join("app", "workers")}
        #{Rails.root.join("app", "workers", "sneakers")}
        #{Rails.root.join("app", "graphql")}
        #{Rails.root.join("app", "graphql", "resolvers")}
        #{Rails.root.join("app", "graphql", "resolvers", "concerns")}
        #{Rails.root.join("app", "controllers", "concerns")}
        #{Rails.root.join("app", "models", "concerns")}
        #{Rails.root.join("app", "queries")}
      ]

    # include JWT middleware
    config.middleware.use ::JwtMiddleware

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: %i[get post put options]
      end
    end
  end
end
