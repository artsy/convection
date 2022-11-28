# frozen_string_literal: true

module Mutations
  class CreateOfferMutation < Mutations::BaseMutation
    argument :submission_id, ID, required: true
    argument :gravity_partner_id, String, required: true
    argument :commission_percent_whole, Integer, required: true

    argument :created_by_id, String, required: false
    argument :currency, String, required: false
    argument :deadline_to_consign, String, required: false
    argument :high_estimate_dollars, Integer, required: false
    argument :insurance_info, String, required: false
    argument :low_estimate_dollars, Integer, required: false
    argument :notes, String, required: false
    argument :offer_type, String, required: false
    argument :other_fees_info, String, required: false
    argument :partner_info, String, required: false
    argument :photography_info, String, required: false
    argument :sale_date, Types::DateType, required: false
    argument :sale_name, String, required: false
    argument :shipping_info, String, required: false
    argument :state, String, required: false
    argument :sale_location, String, required: false
    argument :starting_bid_dollars, Integer, required: false

    field :consignment_offer, Types::OfferType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = CreateOfferResolver.new(**resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
