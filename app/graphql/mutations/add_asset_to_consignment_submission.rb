# frozen_string_literal: true

module Mutations
  class AddAssetToConsignmentSubmission < Mutations::BaseMutation
    argument :gemini_token, String, required: true
    argument :submissionID, ID, required: false
    argument :external_submission_id, ID, required: false
    argument :sessionID, String, required: false
    argument :asset_type, String, required: false
    argument :filename, String, required: false
    argument :size, String, required: false

    field :asset, Types::AssetType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = AddAssetToSubmissionResolver.new(**resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
