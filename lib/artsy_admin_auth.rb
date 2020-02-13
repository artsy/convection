# frozen_string_literal: true

class ArtsyAdminAuth
  class << self
    def decode_token(token)
      return nil if token.blank?

      decoded_token, _headers = JWT.decode(token, Convection.config.jwt_secret)
      decoded_token
    end

    def valid?(token)
      decoded_token = decode_token(token)
      return false if decoded_token.nil?

      decoded_token['roles'].include? 'admin'
    end

    def decode_user(token)
      decoded_token = decode_token(token)
      decoded_token&.fetch('sub', nil)
    end
  end
end
