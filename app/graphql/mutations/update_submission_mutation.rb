# frozen_string_literal: true

module Mutations
  class UpdateSubmissionMutation < Mutations::BaseMutation
    argument :id, ID, required: false
    argument :external_id, ID, required: false

    argument :additional_info, String, required: false
    argument :artistID, String, required: false
    argument :attribution_class, Types::AttributionClassType, required: false
    argument :authenticity_certificate, Boolean, required: false
    argument :category, Types::CategoryType, required: false
    argument :currency, String, required: false
    argument :depth, String, required: false
    argument :dimensions_metric,
             String,
             required: false,
             prepare: ->(value, _context) { value.downcase }
    argument :edition, Boolean, required: false
    argument :edition_number, String, required: false
    argument :edition_size,
             Integer,
             required: false,
             description: 'Deprecated: Use edition_size_formatted field instead'
    argument :edition_size_formatted, String, required: false
    argument :height, String, required: false
    argument :location_city, String, required: false
    argument :location_country, String, required: false
    argument :location_state, String, required: false
    argument :location_postal_code, String, required: false
    argument :medium, String, required: false
    argument :minimum_price_dollars, Int, required: false
    argument :provenance, String, required: false
    argument :signature, Boolean, required: false
    argument :state, Types::StateType, required: false
    argument :title, String, required: false
    argument :width, String, required: false
    argument :year, String, required: false
    argument :user_name, String, required: false
    argument :user_email, String, required: false
    argument :user_phone, String, required: false
    argument :utm_source, String, required: false
    argument :utm_medium, String, required: false
    argument :utm_term, String, required: false
    argument :sessionID, String, required: false

    field :consignment_submission, Types::SubmissionType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = UpdateSubmissionResolver.new(resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
