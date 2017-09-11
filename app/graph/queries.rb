module Queries
  Root = GraphQL::ObjectType.define do
    name 'Root Query'
    description 'Query root for this schema'
    field :submission, types[Types::SubmissionType] do
      description 'Find Submissions'
      argument :ids, types[types.ID]
      argument :id, types.ID
      resolve ->(_object, args, _context) {
        args[:ids] ? Submission.where(id: args[:ids]) : [Submission.find(args[:id])]
      }
    end
  end
end
