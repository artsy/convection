# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication

    def update
      # id in request == sale_id
      artworks_price = fetch_artworks_price(params[:id])

      update_price(artworks_price)
      render json: { result: 'ok' }, status: :created
    end

    private

    def update_price(artworks_price)
      artworks_price.each do |artwork_price|
        submission = Submission.find_by(source_artwork_id: artwork_price[:artwork_id])
        next unless submission

        consignment = submission.consigned_partner_submission
        consignment.assign_attributes(sale_price_cents: artwork_price[:price])
        consignment.save!
      end
    end

    def fetch_artworks_price(id)
      sale_artworks = Gravity.client.sales(id: id).sale_artworks

      sale_artworks.map do |sale_artwork|
        artwork_id = sale_artwork.artwork.id
        price = sale_artwork.highest_bid.try(:amount_cents)
        [artwork_id: artwork_id, price: price]
      end
    end
  end
end
