# frozen_string_literal: true

require 'net/http'
require 'uri'

class Metaql
  module Schema
    def self.execute(query:, x_app_token:, variables: {})
      response =
        Net::HTTP.post(
          URI("#{Convection.config.metaphysics_api_url}"),
          { query: query, variables: variables }.to_json,
          'X-ACCESS-TOKEN' => x_app_token,
          'Content-Type' => 'application/json'
        )

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
