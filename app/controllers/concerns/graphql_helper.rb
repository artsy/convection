# frozen_string_literal: true

module GraphqlHelper
  extend ActiveSupport::Concern

  ARTISTS_DETAILS_QUERY =
    '
  query artistsDetails($ids: [ID!]!){
    artists(ids: $ids){
      id
      name
    }
  }
  '

  MATCH_PARTNERS_QUERY =
    '
  query matchPartners($term: String!) {
    match_partners(term: $term){
      id
      given_name
    }
  }
  '

  def artists_query(artist_ids)
    artist_details_response =
      Gravql::Schema.execute(
        query: ARTISTS_DETAILS_QUERY, variables: { ids: artist_ids.uniq }
      )
    if artist_details_response[:errors].present?
      flash.now[:error] = 'Error fetching artist details.'
    end
    return if artist_details_response.try(:[], :data).try(:[], :artists).blank?

    artist_details_response[:data][:artists].map { |h| [h[:id], h[:name]] }.to_h
  end

  def match_partners_query(term)
    match_partners_response =
      Gravql::Schema.execute(
        query: MATCH_PARTNERS_QUERY, variables: { term: term }
      )
    if match_partners_response[:errors].present?
      flash.now[:error] = 'Error fetching partner details.'
    end
    if match_partners_response.try(:[], :data).try(:[], :match_partners).blank?
      return
    end

    match_partners_response[:data][:match_partners]
  end
end
