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

      # TODO: remove 'admin' once the connsignments team all have this new role
      roles = decoded_token['roles']
      roles.include?('consignments_manager') || roles.include?('admin')
    end

    def decode_user(token)
      decoded_token = decode_token(token)
      decoded_token&.fetch('sub', nil)
    end
  end
end
