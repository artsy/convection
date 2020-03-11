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

    def self.resolve(_obj, args, context)
      params = args.to_h['input'].except('clientMutationId')
      client_mutation_id = args.to_h['input']['clientMutationId']

      # Metaphysics uses camelCase properties and inputs
      params = params.transform_keys(&:underscore)

      submission = Submission.find_by(id: params['id'])
      unless submission
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
      end

      is_same_as_user =
        submission&.user&.gravity_user_id == context[:current_user]
      is_admin = context[:current_user_roles].include?(:admin)
      unless is_same_as_user || is_admin
        raise(GraphQL::ExecutionError, 'Submission Not Found')
      end

      # FIXME: Why does the API reject this property?
      params.delete('dimensions_metric')

      SubmissionService.update_submission(submission, params.except('id'))
      OpenStruct.new(
        consignmentSubmission: submission,
        client_mutation_id: client_mutation_id
      )
    end
  end
end
