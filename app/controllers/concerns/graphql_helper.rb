# frozen_string_literal: true

module GraphqlHelper
  extend ActiveSupport::Concern

  def artists_query(artist_ids)
    artist_details_response = Gravql.artists_details(ids: artist_ids.uniq)

    if artist_details_response.errors.present?
      flash.now[:error] = 'Error fetching artist details.'
    end

    artist_details_response.data&.artists&.map { [_1.id, _1.name] }&.to_h
  end

  def match_partners_query(term)
    match_partners_response = Gravql.match_partners(term: term)

    if match_partners_response.errors.present?
      flash.now[:error] = 'Error fetching partner details.'
    end

    match_partners_response.data&.match_partners&.map(&:to_h)
  end
end
