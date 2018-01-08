module Admin
  class OffersController < ApplicationController
    include GraphqlHelper

    before_action :set_offer, only: [:show, :edit, :update, :destroy]
    before_action :set_pagination_params, only: [:index]

    expose(:offers) do
      matching_offers = params[:state] ? Offer.where(state: params[:state]) : Offer.all
      matching_offers.order(id: :desc).page(@page).per(@size)
    end

    expose(:filters) do
      { state: params[:state] }
    end

    expose(:counts) do
      Offer.group(:state).count
    end

    expose(:offers_count) do
      Offer.count
    end

    expose(:partner) do
      Partner.find(params[:partner_id]) if params[:partner_id].present?
    end

    expose(:submission) do
      Submission.find(params[:submission_id]) if params[:submission_id].present?
    end

    expose(:consignment) do
      @offer.partner_submission if @offer.state == 'accepted'
    end

    def new_step_0
      @offer = Offer.new
      @submission = Submission.find(params[:submission_id]) if params[:submission_id]
    end

    def new_step_1
      @offer = Offer.new(offer_type: params[:offer_type])

      if params[:submission_id].present? && params[:partner_id].present? && params[:offer_type].present?
        render 'new_step_1'
      else
        flash.now[:error] = 'Offer requires type, submission, and partner.'
        render 'new_step_0'
      end
    end

    def create
      @offer = OfferService.create_offer(params[:submission_id], params[:partner_id], offer_params)
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

    def index; end

    private

    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(
        :commission_percent,
        :created_by_id,
        :currency,
        :high_estimate_cents,
        :insurance_cents,
        :insurance_percent,
        :low_estimate_cents,
        :notes,
        :offer_type,
        :other_fees_cents,
        :other_fees_percent,
        :photography_cents,
        :price_cents,
        :rejection_reason,
        :rejection_note,
        :sale_date,
        :sale_name,
        :sale_period_end,
        :sale_period_start,
        :shipping_cents,
        :state
      )
    end
  end
end
