module Admin
  class ConsignmentsController < ApplicationController
    include GraphqlHelper

    before_action :set_consignment, only: [:show, :edit, :update]
    before_action :set_pagination_params, only: [:index]

    expose(:consignments) do
      params.delete(:state) if params[:state] == 'all'
      matching_consignments = PartnerSubmission.consigned
      matching_consignments = matching_consignments.search(params[:term]) if params[:term].present?
      matching_consignments = matching_consignments.where(state: params[:state]) if params[:state].present?
      matching_consignments.order(id: :desc).page(@page).per(@size)
    end

    expose(:filters) do
      { state: params[:state] }
    end

    expose(:counts) do
      PartnerSubmission.consigned.group(:state).count
    end

    expose(:consignments_count) do
      PartnerSubmission.consigned.count
    end

    expose(:term) do
      params[:term]
    end

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

    def index; end

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
        :state,
        :partner_commission_percent,
        :artsy_commission_percent,
        :partner_invoiced_at,
        :partner_paid_at,
        :notes
      )
    end
  end
end
