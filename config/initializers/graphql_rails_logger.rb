# frozen_string_literal: true

GraphQL::RailsLogger.configure do |config|
  config.white_list = { 'Api::GraphqlController' => %w[execute] }
end
