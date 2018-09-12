module Api
  class UsersController < BaseController
    before_action :require_trusted_app
    def anonymize_user_email
      param! :email, String, required: true
      email = params[:email]
      UserService.anonymize_email!(email)
      render json: { result: 'ok' }, status: :created
    end
  end
end
