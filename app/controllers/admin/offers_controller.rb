module Admin
  class OffersController < ApplicationController
    include GraphqlHelper

    before_action :set_offer, only: [:show, :edit, :update, :destroy]

    expose :offer

    expose(:offers) do
      matching_offers = Offer.all
      matching_offers = matching_offers.search(params[:term]) if params[:term].present?

      if params[:partner].present?
        partner = Partner.find(params[:partner])
        matching_offers = partner.offers
      end

      if params[:user].present?
        user = User.find(params[:user])
        matching_offers = matching_offers.where(submission: user.submissions)
      end

      matching_offers = matching_offers.where(state: params[:state]) if params[:state].present?

      sort = params[:sort].presence || 'id'
      direction = params[:direction].presence || 'asc'
      matching_offers = if sort.include?('partners')
                          matching_offers.includes(:partner_submission).includes(:partner).reorder("#{sort} #{direction}")
                        elsif sort.include?('submissions')
                          matching_offers.includes(:submission).reorder("#{sort} #{direction}")
                        else
                          matching_offers.reorder("#{sort} #{direction}")
                        end

      matching_offers.page(page).per(size)
    end

    expose(:filters) do
      { state: params[:state], partner: params[:partner], user: params[:user], sort: params[:sort], direction: params[:direction] }
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

    expose(:term) do
      params[:term]
    end

    expose(:artist) do
      artists_query([offer.submission.artist_id])
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
