# frozen_string_literal: true

Fabricator(:artist_standing_score) do
  artist_id { Fabricate.sequence(:artist_id) }
  artist_score 0.69
  auction_score 0.72
end
