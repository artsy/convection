# frozen_string_literal: true
class ApplicationController < ArtsyAuth::ApplicationController
  NotAuthorized = Class.new(StandardError)

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception

  # override application to decode token and allow only users with `admin` role
  def authorized_artsy_token?(token)
    decoded_token, _headers = JWT.decode(token, Convection.config.jwt_secret)
    decoded_token['roles'].include? 'admin'
  end
end
