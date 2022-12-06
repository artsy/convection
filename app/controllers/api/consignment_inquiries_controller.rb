module Api
  class ConsignmentInquiriesController < RestController
    before_action :require_trusted_app_without_current_user, only: %i[create]

    def create
      param! :email, String, required: true
      param! :name, String, required: true
      param! :message, String, required: true
      param! :phone_number, String, required: false
      param! :gravity_user_id, String, required: false
      consignment_inquiry = ConsignmentInquiry.create!(consignment_inquiry_params)
      render json: consignment_inquiry.to_json, status: :created
    end

    private

    def require_trusted_app_without_current_user
      has_trusted_app =
        current_app.present? &&
          current_user_roles.include?(:trusted)
      return if has_trusted_app

      raise ApplicationController::NotAuthorized
    end

    def consignment_inquiry_params
      params
        .permit(
          :email,
          :gravity_user_id,
          :message,
          :name,
          :phone_number
        )
    end
  end
end
