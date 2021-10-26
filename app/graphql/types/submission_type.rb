# frozen_string_literal: true

module Types
  class SubmissionType < Types::BaseObject
    description 'Consignment Submission'

    field :additional_info, String, null: true
    field :artist_id, String, null: false
    field :assets, [Types::AssetType, { null: true }], null: true
    field :attribution_class, Types::AttributionClassType, null: true
    field :authenticity_certificate, Boolean, null: true
    field :category, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :currency, String, null: true
    field :depth, String, null: true
    field :dimensions_metric, String, null: true
    field :edition, String, null: true
    field :edition_number, String, null: true
    field :edition_size, Integer, null: true
    field :edition_size_temp, String, null: true
    field :height, String, null: true
    field :id, ID, 'Uniq ID for this submission', null: false
    field :internalID, ID, null: true, method: :id
    field :location_city, String, null: true
    field :location_country, String, null: true
    field :location_state, String, null: true
    field :medium, String, null: true
    field :minimum_price_dollars, Integer, null: true
    field :primary_image, Types::AssetType, null: true
    field :provenance, String, null: true
    field :published_at, GraphQL::Types::ISO8601DateTime, null: true
    field :signature, Boolean, null: true
    field :sourceArtworkID,
          String,
          null: true,
          method: :source_artwork_id,
          description: 'If this artwork exists in Gravity, its ID'
    field :state, Types::StateType, null: true
    field :title, String, null: true
    field :user_agent, String, null: true
    field :user_id, String, null: false
    field :user_name, String, null: true
    field :user_email, String, null: true
    field :user_phone, String, null: true
    field :width, String, null: true
    field :year, String, null: true
    field :utm_source, String, null: true
    field :utm_medium, String, null: true
    field :utm_term, String, null: true

    field :offers, [Types::OfferType], null: false do
      argument :gravity_partner_id, ID, required: true
    end

    def offers(gravity_partner_id:)
      partner = Partner.find_by(gravity_partner_id: gravity_partner_id)
      return [] unless partner

      partner_submission = object.partner_submissions.find_by(partner: partner)
      return [] unless partner_submission

      partner_submission.offers
    end
  end
end
