class Gravql
  module Schema
    def self.execute(query:, variables: {})
      response = Typhoeus.post(
        "#{Convection.config.gravity_api_url}/graphql",
        body: { query: query, variables: variables }.to_json,
        headers: {
          'X-XAPP-TOKEN' => Convection.config.gravity_xapp_token,
          'Content-Type' => 'application/json'
        },
        accept_encoding: 'gzip'
      )
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
