# frozen_string_literal: true

HEADERS = { 'Content-Type' => 'application/json' }.freeze

def stub_graphql_request(query, body)
  stub_request(:post, "#{Convection.config.gravity_api_url}/graphql").
    to_return(body: body.to_json).
    with(
      body: hash_including("query" => /#{query}/),
      headers: {'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'}
    )
end

def stub_gravql_artists(body:)
  stub_graphql_request('artistsDetails', body)
end

def stub_gravql_match_partners(body:)
  stub_graphql_request('matchPartners', body)
end
