module Admin
  class OffersController < ApplicationController
    include GraphqlHelper

    before_action :set_offer, only: [:show, :edit, :update, :destroy]
    before_action :set_pagination_params, only: [:index]

    def new_step_0
      @offer = Offer.new
      @submission = Submission.find(params[:submission_id]) if params[:submission_id]
    end

    def new_step_1
      @offer = Offer.new(offer_type: params[:offer_type])

      if params[:submission_id].present? && params[:partner_id].present? && params[:offer_type].present?
        @submission = Submission.find(params[:submission_id])
        @partner = Partner.find(params[:partner_id])
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
