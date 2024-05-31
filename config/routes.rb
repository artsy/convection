# frozen_string_literal: true

Rails
  .application
  .routes
  .draw do
    namespace :admin do
      resources :submissions do
        member do
          get "salesforce_sync"
          put "undo_approval"
          put "undo_publish"
          put "undo_rejection"
          put "undo_close"
          put "list_artwork"
        end
        resources :assets do
          post :multiple, on: :collection
        end
      end
      resources :notes, only: %i[create]
      resources :partners, only: %i[index create] do
        resources :submissions, only: :index, controller: "partner_submissions"
      end
      resources :offers do
        member do
          put "undo_rejection"
          put "undo_lapse"
        end
        collection do
          get "new_step_0"
          get "new_step_1"
        end
      end
      resources :consignments, only: %i[show edit update index]
      resources :users, only: :index
      resources :admin_users
      root to: "dashboard#index"
    end
    get "/match_artist", to: "admin/submissions#match_artist"
    get "/match_artwork", to: "admin/submissions#match_artwork"
    get "/match_user", to: "admin/submissions#match_user"
    get "/match_user_by_contact_info",
      to: "admin/submissions#match_user_by_contact_info"
    get "/match_partner", to: "admin/partners#match_partner"
    get "system/up"

    root to: redirect("/admin")

    namespace :api do
      resources :submissions, only: %i[create update show index]
      resources :assets, only: %i[create show index destroy]
      resources :consignment_inquiries, only: %i[create]
      namespace :consignments do
        put "update_sale_info"
      end
      post "/callbacks/gemini", to: "callbacks#gemini"
      post "/graphql", to: "graphql#execute"
      put "/anonymize_user_email", to: "users#anonymize_user_email"
    end

    if Rails.env.development?
      mount GraphiQL::Rails::Engine,
        at: "/graphiql",
        graphql_path: "/api/graphql"
    end

    mount ArtsyAuth::Engine => "/"

    require "sidekiq/web"
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use `secure_compare` to stop length information leaking
      ActiveSupport::SecurityUtils.secure_compare(
        username,
        Convection.config.sidekiq_username
      ) &
        ActiveSupport::SecurityUtils.secure_compare(
          password,
          Convection.config.sidekiq_password
        )
    end

    mount Sidekiq::Web => "/admin/sidekiq"
  end
