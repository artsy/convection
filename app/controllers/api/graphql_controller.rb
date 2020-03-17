# frozen_string_literal: true

module Api
  class GraphqlController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_artsy_authentication
    skip_before_action :set_current_user

    def execute
      result =
        RootSchema.execute(
          params[:query],
          variables: params[:variables],
          context: {
            current_application: current_app,
            current_user: current_user,
            current_user_roles: current_user_roles
          }
        )
      render json: result, status: :ok
    end

    private

    # For now, require that signature is valid by verifying payload w/ secret.
    # It must have 'aud', with 'sub' optional to be authenticated.
    #
    # If it has both 'aud' and 'sub', then it is user-scoped, with the user_id in 'sub'.
    # All authorization middleware should grant access as appropriate.
    def jwt_payload
      @jwt_payload ||= request.env['JWT_PAYLOAD']
    end

    def current_app
      @current_app ||= jwt_payload&.fetch('aud', nil)
    end

    def current_user
      @current_user ||= jwt_payload&.fetch('sub', nil)
    end

    def current_user_roles
      @current_user_roles ||=
        jwt_payload&.fetch('roles', nil)&.split(',')&.map(&:to_sym) || []
    end
  end
end
