module Api
  class BaseController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate

    rescue_from RailsParam::Param::InvalidParameterError do |ex|
      render json: { error: ex.message, param: ex.param }, status: :bad_request
    end

    def root
      render 'index'
    end

    private

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        # Compare the tokens in a time-constant manner, to mitigate
        # timing attacks.
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(token),
          ::Digest::SHA256.hexdigest(Convection.config.authentication_token)
        )
      end
    end
  end
end
