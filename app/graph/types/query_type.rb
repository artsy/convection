module Types
  QueryType = GraphQL::ObjectType.define do
    name 'Query'
    description 'Query root for this schema'
    field :submission, types[Types::SubmissionType] do
      description 'Find Submissions'
      argument :ids, types[types.ID]
      argument :id, types.ID
      permit ['admin']

      resolve ->(_object, args, _context) {
        args[:ids] ? Submission.where(id: args[:ids]) : [Submission.find(args[:id])]
      }
    end
  end
end
