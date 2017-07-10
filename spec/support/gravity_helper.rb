GRAVITY_ROOT = {
  _links: {
    artist: {
      href: "#{Convection.config.gravity_api_url}/artists/{id}",
      templated: true
    },
    user: {
      href: "#{Convection.config.gravity_api_url}/users/{id}",
      templated: true
    },
    user_detail: {
      href: "#{Convection.config.gravity_api_url}/user_details/{id}",
      templated: true
    }
  }
}.freeze

HEADERS = { 'Content-Type' => 'application/json' }.freeze

def stub_gravity_root
  stub_gravity_request('', GRAVITY_ROOT)
end

def stub_gravity_request(gravity_resource, body, more_headers = {})
  stub = stub_request(:get, "#{Convection.config.gravity_api_url}#{gravity_resource}")
         .to_return(body: body.to_json, headers: HEADERS)
  stub.with(headers: more_headers) unless more_headers.empty?
end

def stub_gravity_artist(opts = {})
  name = opts[:name] || 'Gob Bluth'
  body = {
    id: 'artistid',
    name: name,
    slug: name.parameterize
  }.deep_merge(opts)
  stub_gravity_request("/artists/#{body[:id]}", body)
end

def stub_gravity_user(opts = {})
  id = opts[:id] || 'userid'
  body = {
    id: id,
    name: 'Jon Jonson',
    _links: {
      user_detail: { href: "#{Convection.config.gravity_api_url}/user_details/#{id}" }
    }
  }.deep_merge(opts)
  stub_gravity_request("/users/#{body[:id]}", body)
end

def stub_gravity_user_detail(opts = {})
  body = {
    id: 'userid',
    receive_sms: true,
    phone: '847-593-7743',
    email: 'user@example.com',
    reset_password_token: 'xyz',
    paddle_number: 1234
  }.deep_merge(opts)
  stub_gravity_request("/user_details/#{body[:id]}", body)
end
