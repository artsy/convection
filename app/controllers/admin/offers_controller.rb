# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber

module Admin
  class OffersController < ApplicationController
    include GraphqlHelper

    before_action :set_offer, only: %i[show edit update destroy]

    expose :offer

    expose(:offers) do
      matching_offers = Offer.all

      if filtering_by_assigned_to?
        matching_offers =
          matching_offers.joins(:submission).where(
            'submissions.assigned_to' => params[:assigned_to]
          )
      end

      if params[:term].present?
        matching_offers = matching_offers.search(params[:term])
      end

      if params[:partner].present?
        partner = Partner.find(params[:partner])
        matching_offers = partner.offers
      end

      if params[:user].present?
        user = User.find(params[:user])
        matching_offers = matching_offers.where(submission: user.submissions)
      end

      if params[:state].present?
        matching_offers =
          if params[:state] == 'sent with response'
            matching_offers.where(state: Offer::SENT).where(
              'offer_responses_count > ?',
              0
            )
          else
            matching_offers.where(state: params[:state])
          end
      end

      sort = params[:sort].presence || 'id'
      direction = params[:direction].presence || 'desc'
      matching_offers =
        if sort.include?('partners')
          matching_offers.includes(:partner_submission).includes(:partner)
            .reorder("#{sort} #{direction}")
        elsif sort.include?('submissions')
          matching_offers.includes(:submission).reorder("#{sort} #{direction}")
        else
          matching_offers.reorder("#{sort} #{direction}")
        end

      matching_offers.page(page).per(size)
    end

    expose(:filters) do
      {
        assigned_to: params[:assigned_to],
        state: params[:state],
        partner: params[:partner],
        user: params[:user],
        sort: params[:sort],
        direction: params[:direction]
      }
    end

    expose(:counts) { Offer.group(:state).count }

    expose(:offers_count) { Offer.count }

    expose(:partner) do
      Partner.find(params[:partner_id]) if params[:partner_id].present?
    end

    expose(:submission) do
      Submission.find(params[:submission_id]) if params[:submission_id].present?
    end

    expose(:term) { params[:term] }

    expose(:artist) do
      artists_query([offer&.partner_submission&.submission&.artist_id])&.values
        &.first
    end

    def filtering_by_assigned_to?
      params.keys.map(&:to_sym).include?(:assigned_to) &&
        params[:assigned_to] != 'all'
    end

    def new_step_0
      @offer = Offer.new
      if params[:submission_id]
        @submission = Submission.find(params[:submission_id])
      end
    end

    def new_step_1
      @offer =
        Offer.new(
          offer_type: params[:offer_type], partner_info: params[:partner_info]
        )

      if params[:submission_id].present? && params[:partner_id].present? &&
           params[:offer_type].present?
        render 'new_step_1'
      else
        flash.now[:error] = 'Offer requires type, submission, and partner.'
        render 'new_step_0'
      end
    end

    def create
      @offer =
        OfferService.create_offer(
          params[:submission_id],
          params[:partner_id],
          offer_params,
          @current_user
        )
      redirect_to admin_offer_path(@offer)
    rescue OfferService::OfferError => e
      flash.now[:error] = e.message
      render 'new_step_1'
    end

    def show
      @artist_details = artists_query([@offer.submission.artist_id])
    end

    def edit; end

    def destroy
      @offer.destroy
      flash[:success] = 'Offer deleted.'
      redirect_to admin_submission_path(@offer.submission)
    end

    def update
      OfferService.update_offer(@offer, @current_user, offer_params)
      redirect_to admin_offer_path(@offer)
    rescue OfferService::OfferError => e
      flash.now[:error] = e.message
      render 'edit'
    end

    def index
      respond_to do |format|
        format.html
        format.json { render json: offers || [] }
      end
    end

    private

    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(
        :commission_percent_whole,
        :created_by_id,
        :currency,
        :deadline_to_consign,
        :high_estimate_dollars,
        :insurance_info,
        :low_estimate_dollars,
        :notes,
        :offer_type,
        :other_fees_info,
        :override_email,
        :partner_info,
        :photography_info,
        :price_dollars,
        :rejection_reason,
        :rejection_note,
        :sale_date,
        :sale_location,
        :sale_name,
        :sale_period_end,
        :sale_period_start,
        :shipping_info,
        :state
      )
    end
  end
end

# rubocop:enable Naming/VariableNumber
