# frozen_string_literal: true

module Mutations
  class CreateOfferMutation < Mutations::BaseMutation
    argument :submission_id, ID, required: true
    argument :gravity_partner_id, String, required: true
    argument :commission_percent_whole, Integer, required: true

    field :consignment_offer, Types::OfferType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments, context: context, object: object
      }
      resolver = CreateOfferResolver.new(resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
