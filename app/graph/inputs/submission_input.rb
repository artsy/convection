module Inputs
  module SubmissionInput
    Create = GraphQL::InputObjectType.define do
      name('CreateSubmission')
      SubmissionInput.args(self)
    end

    Update = GraphQL::InputObjectType.define do
      name('UpdateSubmission')
      argument :id, !types.ID
      SubmissionInput.args(self)
    end

    def self.args(object_type)
      object_type.argument :additional_info, object_type.types.String
      object_type.argument :artist_id, !object_type.types.String
      object_type.argument :authenticity_certificate, object_type.types.Boolean
      object_type.argument :category, object_type.types.String
      object_type.argument :deadline_to_sell, Types::DateType
      object_type.argument :depth, object_type.types.String
      object_type.argument :dimensions_metric, object_type.types.String
      object_type.argument :edition, object_type.types.String
      object_type.argument :edition_number, object_type.types.String
      object_type.argument :edition_size, object_type.types.Int
      object_type.argument :height, object_type.types.String
      object_type.argument :location_city, object_type.types.String
      object_type.argument :location_country, object_type.types.String
      object_type.argument :location_state, object_type.types.String
      object_type.argument :medium, object_type.types.String
      object_type.argument :provenance, object_type.types.String
      object_type.argument :signature, object_type.types.Boolean
      object_type.argument :state, object_type.types.String
      object_type.argument :title, object_type.types.String
      object_type.argument :width, object_type.types.String
      object_type.argument :year, object_type.types.String
    end
  end
end
