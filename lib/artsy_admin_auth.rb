# frozen_string_literal: true

class ArtsyAdminAuth
  CONSIGNEMNTS_MANAGER = "consignments_manager"
  CONSIGNMENTS_REPRESENTATIVE = "consignments_representative"

  class << self
    def decode_token(token)
      return nil if token.blank?

      decoded_token, _headers = JWT.decode(token, Convection.config.jwt_secret)
      decoded_token
    end

    def valid?(token, additional_roles = [])
      allowed_roles = [CONSIGNEMNTS_MANAGER] + additional_roles
      decoded_token = decode_token(token)
      return false if decoded_token.nil?

      roles = decoded_token.fetch("roles", "").split(",")
      allowed_roles.any? { |role| roles.include?(role) }
    end

    def decode_user(token)
      decoded_token = decode_token(token)
      decoded_token&.fetch("sub", nil)
    end

    def consignments_manager?(token)
      valid?(token)
    end
  end
end
