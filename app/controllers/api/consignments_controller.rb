# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication
    before_action :set_submission, only: %i[update]

    def update
      consignment = @submission.consigned_partner_submission
      return unless consignment

      consignment.assign_attributes(consignment_params)
      consignment.save!
      render json: consignment.to_json, status: :created
    end

    def consignment_params
      params.permit(
        :sale_lot_number,
        :sale_date,
        :sale_price_cents,
        :currency
      ).merge(user_agent: request.user_agent)
    end
  end
end
