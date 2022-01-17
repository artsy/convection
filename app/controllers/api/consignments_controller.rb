# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication

    def update_price
      update_sale_info(params[:sale_id])

      render json: { result: 'ok' }, status: :created
    end

    private

    def update_sale_info(sale_id)
      sale = Gravity.client.sale(id: sale_id)._get
      sale_artworks =
        Gravity.client.sale_artworks(sale_id: sale_id).sale_artworks

      sale_artworks.map do |sale_artwork|
        artwork = sale_artwork.artwork
        submission = Submission.find_by(source_artwork_id: artwork.id)
        next unless submission

        submission.assign_attributes(
          title: artwork.title,
          medium: artwork.medium
        )
        submission.save!

        consignment = submission.consigned_partner_submission
        next unless consignment

        price = sale_artwork.highest_bid.try(:amount_cents)
        state = price ? 'sold' : 'bought in'
        consignment.assign_attributes(
          sale_price_cents: price || consignment.sale_price_cents,
          sale_lot_number: sale_artwork.lot_number,
          sale_date: sale.end_date,
          state: state,
          sale_name: sale.name
        )
        consignment.save!
      end
    end
  end
end
