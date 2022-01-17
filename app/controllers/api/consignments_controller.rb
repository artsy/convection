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

      sale_artworks.each do |sale_artwork|
        artwork = sale_artwork.artwork
        submission =
          Submission.with_source_artwork_id.find_by(
            source_artwork_id: artwork.id
          )
        next unless submission

        SubmissionService.update_submission_info(artwork, submission)
        PartnerSubmissionService.update_consignment_info(
          sale,
          sale_artwork,
          submission
        )
      end
    end
  end
end
