# frozen_string_literal: true

module Api
  class ConsignmentsController < RestController
    before_action :require_authentication

    def update_sale_info
      sale = Gravity.client.sale(id: params[:sale_id])._get
      sale_artworks =
        Gravity.client.sale_artworks(sale_id: params[:sale_id]).sale_artworks
      artworks = sale_artworks.map { |sa| [sa, sa.artwork, sa.artwork.id] }
      artwork_ids = artworks.map(&:third)
      submissions = Submission.where(source_artwork_id: artwork_ids)

      artworks.each do |sale_artwork, artwork, artwork_id|
        submission = submissions.find_by(source_artwork_id: artwork_id)
        next unless submission

        SubmissionService.update_submission_info(artwork, submission)
        PartnerSubmissionService.update_consignment_info(
          sale,
          sale_artwork,
          submission
        )
      end

      render json: { result: 'ok' }, status: :created
    end
  end
end
