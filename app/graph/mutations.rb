module Mutations
  CreateConsignmentSubmission = GraphQL::Relay::Mutation.define do
    name 'CreateConsignmentSubmission'

    input_field :additional_info, types.String
    input_field :artist_id, !types.String
    input_field :authenticity_certificate, types.Boolean
    input_field :category, types.String
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
    input_field :provenance, types.String
    input_field :signature, types.Boolean
    input_field :state, types.String
    input_field :title, types.String
    input_field :width, types.String
    input_field :year, types.String

    return_field :consignment_submission, Types::SubmissionType
  end

  Root = GraphQL::ObjectType.define do
    name 'Mutation'

    field :createConsignmentSubmission, CreateConsignmentSubmission.return_type do
      permit :user
      argument :input, CreateConsignmentSubmission.input_type
      resolve ->(_obj, args, context) {
        params = args.to_h['input'].except('clientMutationId')
        client_mutation_id = args.to_h['input']['clientMutationId']
        submission = SubmissionService.create_submission(params, context[:current_user])
        OpenStruct.new(consignment_submission: submission, client_mutation_id: client_mutation_id)
      }
    end

    field :updateConsignmentSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :input, Inputs::SubmissionInput::Update
      permit :user

      resolve ->(_obj, args, context) {
        submission = Submission.find_by(id: args[:input][:id])
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless submission

        is_same_as_user = submission&.user&.gravity_user_id == context[:current_user]
        is_admin = context[:current_user_roles].include?(:admin)

        raise(GraphQL::ExecutionError, 'Submission Not Found') unless is_same_as_user || is_admin
        SubmissionService.update_submission(submission, args[:input].to_h.except(:id))
        submission
      }
    end

    field :addAssetToConsignmentSubmission, Types::AssetType do
      description 'Create an asset'
      argument :submission_id, !types.ID, 'The ID for a submission'
      argument :gemini_token, !types.String, 'The token returned from Gemini'
      argument :asset_type, types.String, 'The type of asset', default_value: 'image'

      resolve ->(_obj, args, context) {
        submission = Submission.find_by(id: args[:submission_id])
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless submission

        is_same_as_user = submission&.user&.gravity_user_id == context[:current_user]
        is_admin = context[:current_user_roles].include?(:admin)

        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless is_same_as_user || is_admin

        asset_props = args.to_h
        asset = submission.assets.create!(asset_props)
        SubmissionService.notify_user(submission.id) if submission.submitted?
        asset
      }
    end
  end
end
