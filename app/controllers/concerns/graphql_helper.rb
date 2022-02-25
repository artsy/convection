# frozen_string_literal: true

module GraphqlHelper
  extend ActiveSupport::Concern

  def artist_query_builder(fields: [])
    <<~GQL
      query artistsDetails($ids: [ID!]!){
        artists(ids: $ids){
          #{[:id, *fields].join(', ')}
        }
      }
    GQL
  end

  def my_collection_create_artwork_mutation_builder
    <<~GQL
      mutation myCollectionAddArtworkMutation(
        $input: MyCollectionCreateArtworkInput!
      ) {
        myCollectionCreateArtwork(input: $input) {
          artworkOrError {
            __typename
            ... on MyCollectionArtworkMutationSuccess {
              artworkEdge {
                node {
                  internalID
                }
              }
            }
            ... on MyCollectionArtworkMutationFailure {
              mutationError {
                message
              }
            }
          }
        }
      }
    GQL
  end

  def create_my_collection_artwork(submission, access_token)
    response =
      Metaql::Schema.execute(
        query: my_collection_create_artwork_mutation_builder,
        access_token: access_token,
        variables: {
          input: my_collection_create_artwork_mutation_params(submission)
        }
      )

    if response[:errors].present?
      Rails
        .logger.error "API error adding submission to My Collection: #{response[:errors]}"

      return nil
    end
    if response.dig(
         :data,
         :myCollectionCreateArtwork,
         :artworkOrError,
         :mutationError
       )
      error_message =
        response.dig(
          :data,
          :myCollectionCreateArtwork,
          :artworkOrError,
          :mutationError,
          :message
        )
      Rails
        .logger.error "GraphQL error adding submission to My Collection: #{error_message}"

      return nil
    end

    submission.update(
      my_collection_artwork_id:
        response.dig(
          :data,
          :myCollectionCreateArtwork,
          :artworkOrError,
          :artworkEdge,
          :node,
          :internalID
        )
    )
  end

  MATCH_PARTNERS_QUERY =
    '
  query matchPartners($term: String!) {
    match_partners(term: $term){
      id
      given_name
    }
  }
  '

  def artists_names_query(artist_ids)
    artist_details_response =
      Gravql::Schema.execute(
        query: artist_query_builder(fields: [:name]),
        variables: {
          ids: artist_ids.uniq.select(&:present?)
        }
      )
    if artist_details_response[:errors].present?
      flash.now[:error] = 'Error fetching artist details.'
    end
    return if artist_details_response.try(:[], :data).try(:[], :artists).blank?

    artist_details_response[:data][:artists].map { |h| [h[:id], h[:name]] }.to_h
  end

  def artists_details_query(artist_ids)
    artist_details_response =
      Gravql::Schema.execute(
        query:
          artist_query_builder(
            fields: ['name', 'is_p1: isP1', 'target_supply: targetSupply']
          ),
        variables: {
          ids: artist_ids.compact.uniq
        }
      )
    if artist_details_response[:errors].present?
      flash.now[:error] = 'Error fetching artist details.'
    end

    artist_details_response.try(:[], :data).try(:[], :artists).presence || {}
  end

  def match_partners_query(term)
    match_partners_response =
      Gravql::Schema.execute(
        query: MATCH_PARTNERS_QUERY,
        variables: {
          term: term
        }
      )
    if match_partners_response[:errors].present?
      flash.now[:error] = 'Error fetching partner details.'
    end
    if match_partners_response.try(:[], :data).try(:[], :match_partners).blank?
      return
    end

    match_partners_response[:data][:match_partners]
  end

  def my_collection_create_artwork_mutation_params(submission)
    {
      submissionId: submission.id.to_s,
      artistIds: [submission.artist_id],
      artworkLocation:
        [
          submission.location_city,
          submission.location_state,
          submission.location_country
        ].delete_if(&:blank?).join(', '),
      category: submission.category,
      date: submission.year,
      depth: submission.depth,
      editionNumber: submission.edition_number,
      editionSize: submission.edition_size,
      externalImageUrls:
        submission.images.map do |image|
          image.original_image&.split('?')&.first
        end,
      height: submission.height,
      attributionClass:
        submission.attribution_class&.upcase || 'UNKNOWN_EDITION',
      medium: submission.medium,
      provenance: submission.provenance,
      title: submission.title,
      width: submission.width
    }
  end
end
