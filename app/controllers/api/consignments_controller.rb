# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication

    def update
      # id in request == sale_id
      sale_artworks = Gravity.client.sales(id: params(id)).sale_artworks
      artworks_price = sale_artworks.map do |sale_artwork|
        artwork_id = sale_artwork.artwork.id
        price = sale_artwork.highest_bid.try(:amount_cents)
        [artwork_id: artwork_id, price: price]
      end

      consignments = update_price(artworks_price)
      render json: { result: 'ok' }, status: :created
    end

    def update_price(artworks_price)
      artworks_price.each do |artwork_price|
        submission = Submission.find_by(source_atrwork_id: artwork_price[:artwork_id])
        return unless submission

        consignment = submission.consigned_partner_submission
        consignment.assign_attributes(sale_price_cents: artwork_price[:price])
        consignment.save!
      end
    end

    def consignment_params
      params.permit(
        :sale_lot_number,
        :sale_date,
        :sale_price_cents,
        :currency
      ).merge(user_agent: request.user_agent)
    end
  end
end
