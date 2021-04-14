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
        variables: { ids: artist_ids.uniq.select(&:present?) }
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
        query: artist_query_builder(fields: [
          'name',
          'is_p1: isP1',
          'target_supply: targetSupply'
        ]),
        variables: { ids: artist_ids.compact.uniq }
      )
    if artist_details_response[:errors].present?
      flash.now[:error] = 'Error fetching artist details.'
    end

    artist_details_response.try(:[], :data).try(:[], :artists).presence || {}
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
