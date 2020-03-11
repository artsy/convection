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

    def self.resolve(_obj, args, context)
      params = args.to_h['input'].except('clientMutationId')
      client_mutation_id = args.to_h['input']['clientMutationId']

      submission = Submission.find_by(id: params['submissionID'])
      unless submission
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
      end

      is_same_as_user =
        submission&.user&.gravity_user_id == context[:current_user]
      is_admin = context[:current_user_roles].include?(:admin)

      unless is_same_as_user || is_admin
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
      end

      params['assetType'] ||= 'image'

      # Metaphysics uses camelCase properties and inputs
      params = params.transform_keys(&:underscore)

      asset = submission.assets.create!(params)
      SubmissionService.notify_user(submission.id) if submission.submitted?
      OpenStruct.new(asset: asset, client_mutation_id: client_mutation_id)
    end
  end
end
