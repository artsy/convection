# frozen_string_literal: true

class Gravql < Artemis::Client
  self.default_context = {
    headers: { 'X-XAPP-TOKEN' => Convection.config.gravity_xapp_token }
  }
end
