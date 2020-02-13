# frozen_string_literal: true

GraphiQL::Rails.config.headers['Authorization'] = lambda do |context|
  "Bearer #{context.session[:access_token]}"
end
