module Admin
  class ConsignmentsController < ApplicationController
    include GraphqlHelper

    before_action :set_consignment, only: [:show, :edit, :update]

    expose(:consignment) do
      PartnerSubmission.consigned.find(params[:id])
    end

    expose(:consignments) do
      matching_consignments = PartnerSubmission.consigned
      matching_consignments = matching_consignments.search(term) if term.present?

      if params[:partner].present?
        partner = Partner.find(params[:partner])
        matching_consignments = partner.partner_submissions.consigned
      end

      if params[:user].present?
        user = User.find(params[:user])
        matching_consignments = matching_consignments.where(submission: user.submissions)
      end

      matching_consignments = matching_consignments.where(state: params[:state]) if params[:state].present?

      sort = params[:sort].presence || 'id'
      direction = params[:direction].presence || 'asc'
      matching_consignments = if sort.include?('partners')
                                matching_consignments.includes(:partner).reorder("#{sort} #{direction}")
                              elsif sort.include?('offers')
                                matching_consignments.joins(:accepted_offer).reorder("#{sort} #{direction}")
                              else
                                matching_consignments.reorder("#{sort} #{direction}")
                              end

      matching_consignments.page(page).per(size)
    end

    expose(:artist_details) do
      artists_query(consignments.map(&:submission).map(&:artist_id))
    end

    expose(:artist) do
      artists_query([consignment.submission&.artist_id])&.values&.first
    end

    expose(:filters) do
      { state: params[:state], partner: params[:partner], user: params[:user], sort: params[:sort], direction: params[:direction] }
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

    def index
      respond_to do |format|
        format.html
        format.json { render json: consignments || [] }
      end
    end

    private

    def set_consignment
      @consignment = PartnerSubmission.consigned.find(params[:id])
    end

    def consignment_params
      params.require(:partner_submission).permit(
        :canceled_reason,
        :currency,
        :sale_price,
        :sale_name,
        :sale_date,
        :sale_location,
        :sale_lot_number,
        :state,
        :partner_commission_percent_whole,
        :artsy_commission_percent_whole,
        :partner_invoiced_at,
        :partner_paid_at,
        :notes
      )
    end
  end
end
