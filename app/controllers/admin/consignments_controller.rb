# frozen_string_literal: true

module Admin
  class ConsignmentsController < ApplicationController
    include GraphqlHelper

    before_action :set_consignment, only: %i[show edit update]

    expose(:display_term) do
      if filters[:user].present?
        User.where(id: filters[:user]).pick(:email)
      elsif filters[:partner].present?
        Partner.where(id: filters[:partner]).pick(:name)
      elsif filters[:artist].present?
        artists_names_query([filters[:artist]])&.values&.first
      end
    end
    expose(:consignment) { PartnerSubmission.consigned.find(params[:id]) }

    expose(:consignments) do
      matching_consignments = PartnerSubmission.consigned

      if filtering_by_assigned_to?
        matching_consignments =
          matching_consignments
            .joins(:submission)
            .where("submissions.assigned_to" => params[:assigned_to])
      end

      if term.present?
        matching_consignments = matching_consignments.search(term)
      end

      if params[:partner].present?
        partner = Partner.find(params[:partner])
        matching_consignments = partner.partner_submissions.consigned
      end

      if params[:user].present?
        user = User.find(params[:user])
        matching_consignments =
          matching_consignments.where(submission: user.submissions)
      end

      if params[:artist].present?
        matching_consignments =
          matching_consignments
            .joins(:submission)
            .where(submissions: {artist_id: params[:artist]})
      end

      if params[:state].present?
        matching_consignments =
          matching_consignments.where(state: params[:state])
      end

      sort = params[:sort].presence || "id"
      direction = params[:direction].presence || "desc"
      matching_consignments =
        if sort.include?("partners")
          matching_consignments
            .includes(:partner)
            .reorder("#{sort} #{direction}, partner_submissions.id desc")
        elsif sort.include?("offers")
          matching_consignments
            .joins(:accepted_offer)
            .reorder("#{sort} #{direction}, partner_submissions.id desc")
        else
          matching_consignments.reorder("#{sort} #{direction}")
        end

      matching_consignments.page(page).per(size)
    end

    expose(:artist_details) do
      artists_ids =
        consignments.filter_map do |consignment|
          consignment.submission&.artist_id
        end
      artists_names_query(artists_ids)
    end

    expose(:artist) do
      artists_names_query([consignment.submission&.artist_id])&.values&.first
    end

    expose(:filters) do
      {
        assigned_to: params[:assigned_to],
        state: params[:state],
        partner: params[:partner],
        user: params[:user],
        artist: params[:artist],
        sort: params[:sort],
        direction: params[:direction]
      }
    end

    expose(:counts) { PartnerSubmission.consigned.group(:state).count }

    expose(:consignments_count) { PartnerSubmission.consigned.count }

    expose(:term) { params[:term] }

    def show
      @artist_details = artists_names_query([@consignment.submission.artist_id])
    end

    def edit; end

    def update
      if @consignment.update(consignment_params)
        redirect_to admin_consignment_path(@consignment)
      else
        flash.now[:error] = @consignment.errors.full_messages
        render "edit"
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

    def filtering_by_assigned_to?
      params.keys.map(&:to_sym).include?(:assigned_to) &&
        params[:assigned_to] != "all"
    end

    def consignment_params
      params
        .require(:partner_submission)
        .permit(
          :canceled_reason,
          :currency,
          :sale_price_dollars,
          :sale_name,
          :sale_date,
          :sale_location,
          :sale_lot_number,
          :state,
          :partner_commission_percent_whole,
          :artsy_commission_percent_whole,
          :invoice_number,
          :partner_invoiced_at,
          :partner_paid_at,
          :notes
        )
    end
  end
end
