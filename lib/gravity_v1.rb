class GravityV1
  class GravityError < StandardError; end

  def self.get(url, params: {}, token: nil)
    base_url = "#{Convection.config.gravity_url}#{url}"
    uri = URI.parse(base_url)
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.request_uri, headers(token))
    response = http.request(req)
    raise GravityV1::GravityError, response.body unless response.is_a? Net::HTTPSuccess

    JSON.parse(response.body)
  end

  def self.post(url, params: {}, token: nil)
    base_url = "#{Convection.config.gravity_url}#{url}"
    uri = URI.parse(base_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", headers(token))
    req.body = params.to_json
    response = http.request(req)
    raise GravityV1::GravityError, response.body unless response.is_a? Net::HTTPSuccess

    JSON.parse(response.body)
  end

  def self.headers(token)
    {
      "X-XAPP-TOKEN" => Convection.config.gravity_xapp_token,
      "X-ACCESS-TOKEN" => token,
      "Accept" => "application/json",
      "User-Agent" => "Convection",
      "Content-Type" => "application/json"
    }
  end
end
