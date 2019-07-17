module GraphqlHelper
  extend ActiveSupport::Concern

  ARTISTS_DETAILS_QUERY = %|
  query artistsDetails($ids: [ID!]!){
    artists(ids: $ids){
      id
      name
    }
  }
  |.freeze

  MATCH_PARTNERS_QUERY = %|
  query matchPartners($term: String!) {
    match_partners(term: $term){
      id
      given_name
    }
  }
  |.freeze

  def artists_query(artist_ids)
    artist_details_response = Gravql::Schema.execute(
      query: ARTISTS_DETAILS_QUERY,
      variables: { ids: artist_ids.uniq }
    )
    flash.now[:error] = 'Error fetching artist details.' if artist_details_response[:errors].present?
    return if artist_details_response.try(:[], :data).try(:[], :artists).blank?
    artist_details_response[:data][:artists].map { |h| [h[:id], h[:name]] }.to_h
  end

  def match_partners_query(term)
    match_partners_response = Gravql::Schema.execute(
      query: MATCH_PARTNERS_QUERY,
      variables: { term: term }
    )
    flash.now[:error] = 'Error fetching partner details.' if match_partners_response[:errors].present?
    return if match_partners_response.try(:[], :data).try(:[], :match_partners).blank?
    match_partners_response[:data][:match_partners]
  end
end
