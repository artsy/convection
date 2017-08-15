module Mutations
  Root = GraphQL::ObjectType.define do
    name 'Mutation'

    field :createSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::CreateSubmissionInput
      resolve ->(_obj, args, context) {
        Submission.create!(args[:submission].to_h.with_indifferent_access.merge(user_id: context[:current_user]))
      }
    end

    field :updateSubmission, Types::SubmissionType do
      description 'Create a submission'
      argument :submission, Inputs::UpdateSubmissionInput
      resolve ->(_obj, args, _context) {
        submission = Submission.find(args[:submission][:id]) || GraphQL::ExecutionError.new('Unknown submission')
        SubmissionService.update_submission(submission, args[:submission].to_h.with_indifferent_access.except(:id))
        submission.reload
      }
    end
  end
end
