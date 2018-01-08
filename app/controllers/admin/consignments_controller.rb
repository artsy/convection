module Admin
  class ConsignmentsController < ApplicationController
    include GraphqlHelper

    before_action :set_consignment, only: [:show, :edit, :update]

    def show
      @artist_details = artists_query([@consignment.submission.artist_id])
      render 'show'
    end

    def edit; end

    def update
      PartnerSubmissionService.update_partner_submission(@consignment, consignment_params)
      redirect_to admin_consignment_path(@consignment)
    rescue PartnerSubmissionService::PartnerSubmissionError => e
      flash.now[:error] = e.message
      render 'edit'
    end

    private

    def set_consignment
      @consignment = PartnerSubmission.consignment.find(params[:id])
    end

    def consignment_params
      params.require(:partner_submission).permit(
        :sale_currency,
        :sale_price_cents,
        :sale_name,
        :sale_date,
        :sale_location,
        :sale_lot_number,
        :partner_commission_percent,
        :artsy_commission_percent,
        :partner_invoiced,
        :partner_paid,
        :notes
      )
    end
  end
end
