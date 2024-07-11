# frozen_string_literal: true

module Mutations
  class UploadSourcesType < Types::BaseInputObject
    argument :buckets, [String], required: false
    argument :keys, [String], required: false
  end

  class AddAssetsToConsignmentSubmission < Mutations::BaseMutation
    argument :gemini_tokens, [String], required: false
    argument :submissionID, ID, required: false
    argument :external_submission_id, ID, required: false
    argument :sessionID, String, required: false
    argument :asset_type, String, required: false
    argument :filename, String, required: false
    argument :size, String, required: false
    argument :sources, UploadSourcesType, required: false

    field :assets, [Types::AssetType], null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }
      resolver = AddAssetsToSubmissionResolver.new(**resolve_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
