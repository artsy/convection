class ArtsyAdminAuth
  def self.valid?(token)
    decoded_token, _headers = JWT.decode(token, Convection.config.jwt_secret)
    decoded_token['roles'].include? 'admin'
  end
end
