module GraphqlHelper
  extend ActiveSupport::Concern

  ARTISTS_DETAILS_QUERY = %|
  query artistsDetails($ids: [ID]!){
    artists(ids: $ids){
      id
      name
    }
  }
  |.freeze

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
