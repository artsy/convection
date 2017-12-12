module Admin
  class OffersController < ApplicationController
    include GraphqlHelper

    before_action :set_offer, only: [:show, :edit, :update]
    before_action :set_pagination_params, only: [:index]

    def new
      @offer = Offer.new
      @submission = Submission.find(params[:submission_id]) if params[:submission_id]
    end

    def create
      offer = OfferService.create_offer(params)
      redirect_to edit_admin_offer_path(offer)
    rescue OfferService::OfferError => e
      flash.now[:error] = e.message
      render 'new'
    end

    def show
      @submission = @offer.partner_submission.submission
      @artist_details = artists_query([@submission.artist_id])
    end

    def edit; end

    def update
      OfferService.update_offer(@offer, offer_params)
      redirect_to admin_offer_path(@offer)
    rescue OfferService::OfferError => e
      flash.now[:error] = e.message
      render 'edit'
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
