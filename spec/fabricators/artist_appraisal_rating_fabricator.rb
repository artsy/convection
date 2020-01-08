Fabricator(:artist_appraisal_rating) do
  artist_id { Fabricate.sequence(:artist_id) }
  score 0.69
end
