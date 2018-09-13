module Mutations
  module UpdateConsignmentSubmission
    Definition = GraphQL::Relay::Mutation.define do
      name 'UpdateConsignmentSubmission'

      input_field :id, !types.ID
      input_field :additional_info, types.String
      input_field :artist_id, types.String
      input_field :authenticity_certificate, types.Boolean
      input_field :category, Types::CategoryType
      input_field :depth, types.String
      input_field :dimensions_metric, types.String
      input_field :edition, types.Boolean
      input_field :edition_number, types.String
      input_field :edition_size, types.Int
      input_field :height, types.String
      input_field :location_city, types.String
      input_field :location_country, types.String
      input_field :location_state, types.String
      input_field :medium, types.String
      input_field :minimum_price_dollars, types.Int
      input_field :provenance, types.String
      input_field :signature, types.Boolean
      input_field :state, Types::StateType
      input_field :title, types.String
      input_field :width, types.String
      input_field :year, types.String

      return_field :consignment_submission, Types::SubmissionType
    end

    def self.resolve(_obj, args, context)
      params = args.to_h['input'].except('clientMutationId')
      client_mutation_id = args.to_h['input']['clientMutationId']

      submission = Submission.find_by(id: params['id'])
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless submission

      is_same_as_user = submission&.user&.gravity_user_id == context[:current_user]
      is_admin = context[:current_user_roles].include?(:admin)
      raise(GraphQL::ExecutionError, 'Submission Not Found') unless is_same_as_user || is_admin

      SubmissionService.update_submission(submission, params.except('id'))
      OpenStruct.new(consignment_submission: submission, client_mutation_id: client_mutation_id)
    end
  end
end
