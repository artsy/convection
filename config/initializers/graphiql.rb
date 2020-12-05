# frozen_string_literal: true

GraphiQL::Rails.config.headers['Authorization'] =
  lambda { |context| "Bearer #{context.session[:access_token]}" }
