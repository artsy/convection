# frozen_string_literal: true

module Api
  class UsersController < RestController
    before_action :require_trusted_app
    def anonymize_user_email
      param! :email, String, required: true
      email = params[:email]
      UserService.anonymize_email!(email)
      render json: { result: 'ok' }, status: :created
    end
  end
end
