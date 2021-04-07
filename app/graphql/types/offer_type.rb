# frozen_string_literal: true

module Types
  class OfferType < Types::BaseObject
    description 'Consignment Offer'

    field :id, ID, 'Uniq ID for this offer', null: false

    field :commission_percent_whole, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_by_id, ID, null: true
    field :currency, String, null: true
    field :deadline_to_consign, String, null: true
    field :high_estimate_cents, Integer, null: true
    field :insurance_info, String, null: true
    field :low_estimate_cents, Integer, null: true
    field :notes, String, null: true
    field :offer_type, String, null: true
    field :other_fees_info, String, null: true
    field :partner_info, String, null: true
    field :photography_info, String, null: true
    field :sale_date, String, null: true
    field :sale_name, String, null: true
    field :sale_location, String, null: true
    field :shipping_info, String, null: true
    field :state, String, null: true
    field :starting_bid_cents, Integer, null: true

    field :submission, Types::SubmissionType, null: false
  end
end
