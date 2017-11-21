module Mutations
  Root = GraphQL::ObjectType.define do
    name 'Mutation'

    field :createSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::SubmissionInput::Create
      permit :user
      resolve ->(_obj, args, context) {
        Submission.create!(args[:submission].to_h.merge(user_id: context[:current_user]))
      }
    end

    field :updateSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::SubmissionInput::Update
      permit :user

      resolve ->(_obj, args, context) {
        submission = Submission.find_by(id: args[:submission][:id])
        raise(GraphQL::ExecutionError, 'Submission Not Found') unless submission&.user_id == context[:current_user]
        SubmissionService.update_submission(submission, args[:submission].to_h.except(:id))
        submission
      }
    end

    field :createAsset, Types::AssetType do
      description 'Create an asset'
      argument :submission_id, !types.Int, 'The ID for a submission'
      argument :gemini_token, !types.String, 'The token returned from Gemini'
      argument :type, types.String, 'The type of asset', default_value: 'image'

      resolve ->(_obj, args, _context) {
        asset = @submission.assets.create!(args)
        SubmissionService.notify_user(@submission.id) if @submission.submitted?
        asset
      }
    end
  end
end
