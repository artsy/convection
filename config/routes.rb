# frozen_string_literal: true
Rails.application.routes.draw do
  namespace :api do
    post '/submissions', to: 'submissions#create'
  end

  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use `secure_compare` to stop length information leaking
    ActiveSupport::SecurityUtils.secure_compare(username, Convection.config.sidekiq_username) &
      ActiveSupport::SecurityUtils.secure_compare(password, Convection.config.sidekiq_password)
  end
  mount Sidekiq::Web => '/admin/sidekiq'
end
