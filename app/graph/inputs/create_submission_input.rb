module Inputs
  CreateSubmissionInput = GraphQL::InputObjectType.define do
    name('CreateSubmission')
    argument :additional_info, types.String
    argument :artist_id, !types.String
    argument :authenticity_certificate, types.String
    argument :category, types.String
    argument :deadline_to_sell, Types::DateType
    argument :depth, types.String
    argument :dimensions_metric, types.String
    argument :edition, types.String
    argument :edition_number, types.String
    argument :edition_size, types.String
    argument :height, types.String
    argument :location_city, types.String
    argument :location_country, types.String
    argument :location_state, types.String
    argument :medium, types.String
    argument :provenance, types.String
    argument :signature, types.String
    argument :state, types.String
    argument :title, types.String
    argument :width, types.String
    argument :year, types.String
  end
end
