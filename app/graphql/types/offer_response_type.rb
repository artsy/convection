# frozen_string_literal: true

module Types
  class OfferResponseType < Types::BaseObject
    description 'Consignment Offer Response'

    field :id, ID, 'Uniq ID for this offer response', null: false
    field :intended_state, Types::IntendedStateType, null: false

    field :phone_number, String, null: true
    field :comments, String, null: true
    field :rejection_reason, String, null: true

    field :offer, Types::OfferType, null: false
  end
end
