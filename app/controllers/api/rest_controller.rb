# frozen_string_literal: true

module Api
  class RestController < BaseController
    rescue_from RailsParam::Param::InvalidParameterError do |error|
      payload = {error: error.message, param: error.param}
      render json: payload, status: :bad_request
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: {error: "Not Found"}, status: :not_found
    end

    rescue_from ApplicationController::NotAuthorized do
      render json: {error: "Unauthorized"}, status: :unauthorized
    end

    rescue_from SubmissionService::ParamError do |error|
      render json: {error: error.message}, status: :bad_request
    end

    private

    def set_submission
      submission_id = params[:id] || params[:submission_id]
      @submission = Submission.find(submission_id)
    end

    def require_trusted_app
      has_trusted_app =
        current_app.present? && current_user.blank? &&
        current_user_roles.include?(:trusted)
      return if has_trusted_app

      raise ApplicationController::NotAuthorized
    end

    def ensure_trusted_app_or_user
      has_trusted_app =
        current_app.present? &&
        (current_user_roles.include?(:trusted) || current_user)
      return if has_trusted_app

      raise ApplicationController::NotAuthorized
    end

    def require_authentication
      has_authentication = current_app && current_user
      return if has_authentication

      raise ApplicationController::NotAuthorized
    end

    def require_authorized_submission
      has_authorized_submission =
        current_user && current_user == @submission.user&.gravity_user_id
      return if has_authorized_submission

      raise ApplicationController::NotAuthorized
    end
  end
end
