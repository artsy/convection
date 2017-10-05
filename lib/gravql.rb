require 'net/http'
require 'uri'

class Gravql
  module Schema
    def self.execute(query:, variables: {})
      response = Net::HTTP.post(
        URI("#{Convection.config.gravity_api_url}/graphql"),
        { query: query, variables: variables }.to_json,
        'X-XAPP-TOKEN' => Convection.config.gravity_xapp_token,
        'Content-Type' => 'application/json'
      )

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
