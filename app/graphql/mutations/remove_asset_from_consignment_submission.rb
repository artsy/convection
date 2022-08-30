# frozen_string_literal: true

module Mutations
  class RemoveAssetFromConsignmentSubmission < Mutations::BaseMutation
    argument :sessionID, String, required: false
    argument :assetID, String, required: false

    field :asset, Types::AssetType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = RemoveAssetFromSubmissionResolver.new(**resolve_options)

      resolver.run
    end
  end
end
