# frozen_string_literal: true

module Mutations
  class CreateOfferResponseMutation < Mutations::BaseMutation
    argument :offer_id, ID, required: true
    argument :intended_state, Types::IntendedStateType, required: true

    argument :phone_number, String, required: false
    argument :comments, String, required: false
    argument :rejection_reason, String, required: false

    field :consignment_offer_response, Types::OfferResponseType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = CreateOfferResponseResolver.new(**resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
