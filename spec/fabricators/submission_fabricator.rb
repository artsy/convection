Fabricator(:submission) do
  user { Fabricate(:user) }
  artist_id { Fabricate.sequence(:artist_id) }
  title { Fabricate.sequence(:title) { |i| "The Last Supper #{i}" } }
  year 2010
  medium 'oil on paper'
  category { Submission::CATEGORIES.first }
  height 10
  width 12
  dimensions_metric 'in'
  signature false
  authenticity_certificate false
  location_city 'New York'
  location_state 'New York'
  location_country 'USA'
end
