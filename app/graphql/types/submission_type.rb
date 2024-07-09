# frozen_string_literal: true

module Types
  class SubmissionType < Types::BaseObject
    description "Consignment Submission"

    field :external_id,
      ID,
      null: false,
      method: :uuid,
      description: "UUID visible to users"
    field :id, ID, "Uniq ID for this submission", null: false
    field :internalID, ID, null: true, method: :id
    field :state, Types::StateType, null: true
    field :rejection_reason, String, null: true
    field :sale_state, String, null: true

    nilable_field :additional_info, String, null: true
    nilable_field :artist_id, String, null: false, default_value: ""
    nilable_field :assets, [Types::AssetType, {null: true}], null: true do
      argument :asset_type, [Types::AssetTypeType], required: false, default_value: []
    end
    nilable_field :attribution_class, Types::AttributionClassType, null: true
    nilable_field :authenticity_certificate, Boolean, null: true
    nilable_field :category, String, null: true
    nilable_field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    nilable_field :currency, String, null: true
    nilable_field :depth, String, null: true
    nilable_field :dimensions_metric, String, null: true
    nilable_field :edition, String, null: true
    nilable_field :edition_number, String, null: true
    nilable_field :edition_size, String, null: true
    nilable_field :height, String, null: true
    nilable_field :location_city, String, null: true
    nilable_field :location_country, String, null: true
    nilable_field :location_state, String, null: true
    nilable_field :location_postal_code, String, null: true
    nilable_field :location_country_code, String, null: true
    nilable_field :medium, String, null: true
    nilable_field :minimum_price_dollars, Integer, null: true
    nilable_field :myCollectionArtworkID, String, null: true, method: :my_collection_artwork_id
    nilable_field :primary_image, Types::AssetType, null: true
    nilable_field :provenance, String, null: true
    nilable_field :published_at, GraphQL::Types::ISO8601DateTime, null: true
    nilable_field :signature, Boolean, null: true
    nilable_field :sourceArtworkID,
      String,
      null: true,
      method: :source_artwork_id,
      description: "If this artwork exists in Gravity, its ID"
    nilable_field :title, String, null: true
    nilable_field :user_agent, String, null: true
    nilable_field :user_id, String, null: false, default_value: -1
    nilable_field :user_name, String, null: true
    nilable_field :user_email, String, null: true
    nilable_field :user_phone, String, null: true
    nilable_field :width, String, null: true
    nilable_field :year, String, null: true
    nilable_field :source, Types::SubmissionSourceType, null: true
    nilable_field :utm_source, String, null: true
    nilable_field :utm_medium, String, null: true
    nilable_field :utm_term, String, null: true

    nilable_field :offers, [Types::OfferType], null: false, default_value: [] do
      argument :gravity_partner_id, ID, required: true
    end

    def offers(gravity_partner_id:)
      partner = Partner.find_by(gravity_partner_id: gravity_partner_id)
      return [] unless partner

      partner_submission = object.partner_submissions.find_by(partner: partner)
      return [] unless partner_submission

      partner_submission.offers
    end

    def sale_state
      sale_state = object.is_a?(Hash) ? object["sale_state"] : object.sale_state

      return sale_state if sale_state
      return nil unless object["consigned_partner_submission_id"]

      begin
        partner_submission =
          PartnerSubmission.find(object["consigned_partner_submission_id"])

        partner_submission&.state
      rescue Faraday::ResourceNotFound
        nil
      end
    end

    def assets(asset_type:)
      asset_type = "image" if asset_type.blank?

      object.assets.where(asset_type: asset_type)
    end
  end
end
