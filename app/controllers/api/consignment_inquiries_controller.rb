module Api
  class ConsignmentInquiriesController < RestController
    before_action :ensure_trusted_app, only: %i[create]

    def create
      param! :email, String, required: true
      param! :name, String, required: true
      param! :message, String, required: true
      param! :phone_number, String, required: false
      param! :gravity_user_id, String, required: false
      consignment_inquiry = ConsignmentInquiry.create!(consignment_inquiry_params)
      ConsignmentInquiryService.post_consignment_created_event(consignment_inquiry)
      render json: consignment_inquiry.to_json, status: :created
    end

    private

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
