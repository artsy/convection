# frozen_string_literal: true

module Mutations
  module AddAssetToConsignmentSubmission
    Definition =
      GraphQL::Relay::Mutation.define do
        name 'AddAssetToConsignmentSubmission'

        input_field :submission_id, !types.ID
        input_field :gemini_token, !types.String
        input_field :asset_type, types.String

        return_field :asset, Types::AssetType
      end

    def self.resolve(_obj, args, context)
      params = args.to_h['input'].except('clientMutationId')
      client_mutation_id = args.to_h['input']['clientMutationId']

      submission = Submission.find_by(id: params['submission_id'])
      unless submission
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
      end

      is_same_as_user =
        submission&.user&.gravity_user_id == context[:current_user]
      is_admin = context[:current_user_roles].include?(:admin)

      unless is_same_as_user || is_admin
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
      end

      params['asset_type'] ||= 'image'
      asset = submission.assets.create!(params)
      SubmissionService.notify_user(submission.id) if submission.submitted?
      OpenStruct.new(asset: asset, client_mutation_id: client_mutation_id)
    end
  end
end
