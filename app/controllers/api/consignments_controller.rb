# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication

    def update_price
      artworks_price = fetch_sale_artworks_with_price(params[:sale_id])

      PartnerSubmissionService.update_price(artworks_price)
      render json: { result: 'ok' }, status: :created
    end

    private

    def fetch_sale_artworks_with_price(sale_id)
      sale_artworks =
        Gravity.client.sale_artworks(sale_id: sale_id).sale_artworks

      sale_artworks.map do |sale_artwork|
        artwork_id = sale_artwork.artwork.id
        price = sale_artwork.highest_bid.try(:amount_cents)
        [artwork_id: artwork_id, price: price]
      end
    end
  end
end
