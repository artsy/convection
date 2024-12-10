# frozen_string_literal: true

def stub_jwt_header(user_id = nil)
  id = user_id || "userid"
  payload_data = {sub: id, aud: "convection"}
  token = JWT.encode payload_data, Convection.config.jwt_secret, "HS256"
  page.set_rack_session(access_token: token)
  {"Authorization" => "Bearer: #{token}"}
end
