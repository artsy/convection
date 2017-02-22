def authorized_headers
  {
    'Authorization' => ActionController::HttpAuthentication::Token.encode_credentials(
      Convection.config.authentication_token
    )
  }
end
