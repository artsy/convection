# frozen_string_literal: true

module Types
  QueryType =
    GraphQL::ObjectType.define do
      name 'Query'
      description 'Query root for this schema'
      field :submission, Types::SubmissionType do
        description 'Get a Submission'
        argument :id, types.ID

        resolve lambda { |object, arguments, context|
                  resolve_options = {
                    arguments: arguments, context: context, object: object
                  }
                  resolver = SubmissionResolver.new(resolve_options)
                  raise resolver.error unless resolver.valid?

                  resolver.run
                }
      end

      connection :submissions, Types::SubmissionType.define_connection do
        description 'Filter all submission'

        argument :ids, types[types.ID], 'Get all submissions with these IDs'
        argument :user_id,
                 types[types.ID],
                 'Only get submission by this user_id'

        argument :completed,
                 types.Boolean,
                 'If present return either completed or not completed submissions'

        resolve lambda { |object, arguments, context|
                  resolve_options = {
                    arguments: arguments, context: context, object: object
                  }
                  resolver = SubmissionsResolver.new(resolve_options)
                  raise resolver.error unless resolver.valid?

                  resolver.run
                }
      end
    end
end
