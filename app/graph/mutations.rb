module Mutations
  Root = GraphQL::ObjectType.define do
    name 'Mutation'

    field :createSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::SubmissionInput::Create
      permit :user
      resolve ->(_obj, args, context) {
        SubmissionService.create_submission(args[:submission].to_h, context[:current_user])
      }
    end

    field :updateSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::SubmissionInput::Update
      permit :user

      resolve ->(_obj, args, context) {
        submission = Submission.find_by(id: args[:submission][:id])
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless submission

        is_same_as_user = submission&.user&.gravity_user_id == context[:current_user]
        is_admin = context[:current_user_roles].include?(:admin)

        raise(GraphQL::ExecutionError, 'Submission Not Found') unless is_same_as_user || is_admin
        SubmissionService.update_submission(submission, args[:submission].to_h.except(:id))
        submission
      }
    end

    field :createAsset, Types::AssetType do
      description 'Create an asset'
      argument :submission_id, !types.ID, 'The ID for a submission'
      argument :gemini_token, !types.String, 'The token returned from Gemini'
      argument :type, types.String, 'The type of asset', default_value: 'image'

      resolve ->(_obj, args, context) {
        submission = Submission.find_by(id: args[:submission_id])
        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless submission

        is_same_as_user = submission&.user&.gravity_user_id == context[:current_user]
        is_admin = context[:current_user_roles].include?(:admin)

        raise(GraphQL::ExecutionError, 'Submission from ID Not Found') unless is_same_as_user || is_admin

        asset_props = args.to_h
        asset_props['asset_type'] = asset_props['type']
        asset = submission.assets.create!(asset_props.except('type'))
        SubmissionService.notify_user(submission.id) if submission.submitted?
        asset
      }
    end
  end
end
