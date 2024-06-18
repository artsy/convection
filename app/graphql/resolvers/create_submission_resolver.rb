# frozen_string_literal: true

class CreateSubmissionResolver < BaseResolver
  def run
    arguments = @arguments[:source_from_my_collection_artwork] ? artwork_arguments : @arguments

    SubmissionService.create_submission(
      arguments,
      @context[:current_user],
      is_convection: false
    )

    {consignment_submission: submission}
  end

  private

  def artwork
    artwork ||= artwork_details_query(@arguments[:myCollectionArtworkID])
  end

  def my_collection_artwork_arguments
    {
      artistID: artwork.artist&.internalID,
      title: artwork.title || "",
      medium: artwork.medium || "",
      category: format_category_value_for_submission(artwork.mediumType.name),
      year: artwork.date || "",
      attributionClass: artwork.attributionClass&.name&.replace("_", " ")&.toLowerCase,
      editionNumber: artwork.editionNumber || "",
      editionSize: artwork&.editionSize,
      height: artwork.height || "",
      width: artwork.width || "",
      depth: artwork.depth || "",
      dimensionsMetric: artwork.metric || "in",
      provenance: artwork.provenance || "",
      locationCity: artwork.collectorLocation&.city,
      locationCountry: artwork.collectorLocation&.country,
      locationState: artwork.collectorLocation&.state,
      locationCountryCode: artwork.collectorLocation&.countryCode,
      locationPostalCode: artwork.collectorLocation&.postalCode,
      state: "DRAFT",
    }
  end
end
