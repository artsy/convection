module Queries
  Root = GraphQL::ObjectType.define do
    name 'Root Query'
    description 'Query root for this schema'
    field :submission, types[Types::SubmissionType] do
      description 'Find Submissions'
      argument :ids, !types[types.ID]
      resolve ->(_object, arguments, _context) {
        Submission.where(id: arguments['ids'])
      }
    end
  end
end
