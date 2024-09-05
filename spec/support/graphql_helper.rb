def stub_graphql_artwork_request(id = nil)
  mock_artwork_data = {
    condition: {
      displayText: "Excellent", description: "Like new"
    },
    isFramed: true,
    framedHeight: 30,
    framedWidth: 30,
    framedMetric: "cm"
  }

  stub = stub_request(:post, Convection.config.metaphysics_api_url)
  stub.with(body: /#{Regexp.quote(id)}/) if id.present?
  stub.to_return(status: 200, body: {data: {artwork: mock_artwork_data}}.to_json, headers: {})
end
