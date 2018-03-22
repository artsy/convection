module Mutations
  Root = GraphQL::ObjectType.define do
    name 'Mutation'

    field :createConsignmentSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :input, Inputs::SubmissionInput::Create
      permit :user
      resolve ->(_obj, args, context) {
        SubmissionService.create_submission(args[:input].to_h, context[:current_user])
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
