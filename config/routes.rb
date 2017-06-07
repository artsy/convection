# frozen_string_literal: true
Rails.application.routes.draw do
  namespace :admin do
    resources :assets
    resources :submissions

    root to: 'assets#index'
  end

  get 'system/up'

  root to: 'submissions#index'

  namespace :api do
    resources :submissions, only: [:create, :update, :show]
    resources :assets, only: [:create, :show, :index]
    post '/callbacks/gemini', to: 'callbacks#gemini'
  end

  mount ArtsyAuth::Engine => '/'

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
