# frozen_string_literal: true

module Mutations
  module UpdateSubmissionMutation
    Definition =
      GraphQL::Relay::Mutation.define do
        name 'UpdateSubmissionMutation'

        input_field :id, !types.ID
        input_field :additionalInfo, types.String
        input_field :artistID, types.String
        input_field :authenticityCertificate, types.Boolean
        input_field :category, Types::CategoryType
        input_field :currency, types.String
        input_field :depth, types.String
        input_field :dimensionsMetric, types.String
        input_field :edition, types.Boolean
        input_field :editionNumber, types.String
        input_field :editionSize, types.Int
        input_field :height, types.String
        input_field :locationCity, types.String
        input_field :locationCountry, types.String
        input_field :locationState, types.String
        input_field :medium, types.String
        input_field :minimumPriceDollars, types.Int
        input_field :provenance, types.String
        input_field :signature, types.Boolean
        input_field :state, Types::StateType
        input_field :title, types.String
        input_field :width, types.String
        input_field :year, types.String

        return_field :consignmentSubmission, Types::SubmissionType
      end

    def self.resolve(object, arguments, context)
      resolve_options = {
        arguments: arguments, context: context, object: object
      }
      resolver = UpdateSubmissionResolver.new(resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
