module GraphqlHelper
  extend ActiveSupport::Concern

  PARTNER_DETAILS_QUERY = %|
    query partnersDetails($ids: [ID]!){
      partners(ids: $ids){
        id
        given_name
      }
    }
  |.freeze

  ARTISTS_DETAILS_QUERY = %|
  query artistsDetails($ids: [ID]!){
    artists(ids: $ids){
      id
      name
    }
  }
  |.freeze

  def partners_query(partner_ids)
    partners_details_response = Gravql::Schema.execute(
      query: PARTNER_DETAILS_QUERY,
      variables: { ids: partner_ids }
    )
    flash.now[:error] = 'Error fetching some partner details.' if partners_details_response[:errors].present?
    return unless partners_details_response.try(:[], :data).try(:[], :partners).present?
    partners_details_response[:data][:partners].map { |pd| [pd[:id], pd] }.to_h
  end

  def artists_query(artist_ids)
    artist_details_response = Gravql::Schema.execute(
      query: ARTISTS_DETAILS_QUERY,
      variables: { ids: artist_ids.uniq }
    )
    flash.now[:error] = 'Error fetching artist details.' if artist_details_response[:errors].present?
    return unless artist_details_response.try(:[], :data).try(:[], :artists).present?
    artist_details_response[:data][:artists].map { |h| [h[:id], h[:name]] }.to_h
  end
end
