module Admin
  class ConsignmentsController < ApplicationController
    include GraphqlHelper

    before_action :set_consignment, only: [:show, :edit, :update]

    def show
      @artist_details = artists_query([@consignment.submission.artist_id])
    end

    def edit; end

    def update
      if @consignment.update(consignment_params)
        redirect_to admin_consignment_path(@consignment)
      else
        flash.now[:error] = @consignment.errors.full_messages
        render 'edit'
      end
    end

    private

    def set_consignment
      @consignment = PartnerSubmission.consigned.find(params[:id])
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
