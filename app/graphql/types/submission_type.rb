# frozen_string_literal: true

module Types
  class SubmissionType < Types::BaseObject
    description 'Consignment Submission'

    field :additional_info, String, null: true
    field :artist_id, String, null: false
    field :assets, [Types::AssetType, null: true], null: true
    field :authenticity_certificate, Boolean, null: true
    field :category, Types::CategoryType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :currency, String, null: true
    field :depth, String, null: true
    field :dimensions_metric, String, null: true
    field :edition, String, null: true
    field :edition_number, String, null: true
    field :edition_size, Integer, null: true
    field :height, String, null: true
    field :id, ID, 'Uniq ID for this submission', null: false
    field :internal_id, ID, method: :id, null: true # Alias for MPv2 compatability
    field :location_city, String, null: true
    field :location_country, String, null: true
    field :location_state, String, null: true
    field :medium, String, null: true
    field :minimum_price_dollars, Integer, null: true
    field :provenance, String, null: true
    field :signature, Boolean, null: true
    field :state, Types::StateType, null: true
    field :title, String, null: true
    field :user_id, String, null: false
    field :width, String, null: true
    field :year, String, null: true
  end
end
