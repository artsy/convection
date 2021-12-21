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
      sale = Gravity.client.sales(sale_id).sales # return array, but i need .sale(id).sale which exist but doesnt work, need investigate
      sale_artworks =
        Gravity.client.sale_artworks(sale_id: sale_id).sale_artworks

      sale_artworks.map do |sale_artwork|
        artwork = sale_artwork.artwork # sometimes doesnt work
        submission = Submission.find_by(source_artwork_id: artwork.id)
        next unless submission

        # submission update
        submission.assign_attributes(
          title: artwork.title,
          medium: artwork.medium,
          year: artwork.year
        )

        # do we need to update artist name here? in some cases artwork can have multiple artists, why? and which one to indicate?

        # consignment update
        price = sale_artwork.highest_bid.try(:amount_cents)
        lot_number = sale_artwork.lot_number
        sale_date = sale.end_date
        state = price ? 'sold' : 'bought in'
        consignment = submission.consigned_partner_submission
        consignment.assign_attributes(
          sale_price_cents: price,
          sale_lot_number: lot_number,
          sale_date: sale_date,
          state: state,
          sale_name: sale.name
        )
      end
    end
  end
end
