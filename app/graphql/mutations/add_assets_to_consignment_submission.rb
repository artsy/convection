# frozen_string_literal: true

module Mutations
  class AddAssetsToConsignmentSubmission < Mutations::BaseMutation
    argument :gemini_tokens, [String], required: true
    argument :submissionID, ID, required: true

    argument :asset_type, String, required: false

    field :asset, Types::AssetType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = AddAssetsToSubmissionResolver.new(resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
