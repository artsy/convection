module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_artsy_authentication
    skip_before_action :set_current_user

    rescue_from RailsParam::Param::InvalidParameterError do |ex|
      render json: { error: ex.message, param: ex.param }, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do |_ex|
      render json: { error: 'Not Found' }, status: 404
    end

    rescue_from ApplicationController::NotAuthorized do |_ex|
      render json: { error: 'Unauthorized' }, status: 401
    end

    rescue_from SubmissionService::ParamError do |ex|
      render json: { error: ex.message }, status: 400
    end

    def set_submission
      submission_id = params[:id] || params[:submission_id]
      @submission = Submission.find(submission_id)
    end

    def require_authentication
      raise ApplicationController::NotAuthorized unless current_app && current_user
    end

    def require_authorized_submission
      raise ApplicationController::NotAuthorized unless current_user && current_user == @submission.user_id
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
      @current_user_roles ||= jwt_payload&.fetch('roles', '')&.split(',')
    end
  end
end
