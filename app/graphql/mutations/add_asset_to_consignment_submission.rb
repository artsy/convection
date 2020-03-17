# frozen_string_literal: true

module Mutations
  module AddAssetToConsignmentSubmission
    Definition =
      GraphQL::Relay::Mutation.define do
        name 'AddAssetToConsignmentSubmission'

        input_field :submissionID, !types.ID
        input_field :geminiToken, !types.String
        input_field :assetType, types.String

        return_field :asset, Types::AssetType
      end

    def self.resolve(object, arguments, context)
      resolve_options = {
        arguments: arguments, context: context, object: object
      }
      resolver = AddAssetToSubmissionResolver.new(resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
