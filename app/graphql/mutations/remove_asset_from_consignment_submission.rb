# frozen_string_literal: true

module Mutations
    class RemoveAssetFromConsignmentSubmission < Mutations::BaseMutation
      argument :gemini_token, String, required: true
      argument :submissionID, ID, required: true
      argument :sessionID, String, required: false
  
      field :asset, Types::AssetType, null: true
  
      def resolve(arguments)
        resolve_options = {
          arguments: arguments,
          context: context,
          object: object
        }
        resolver = RemoveAssetFromSubmissionResolver.new(resolve_options)
        raise resolver.error unless resolver.valid?
  
        resolver.run
      end
    end
  end
  