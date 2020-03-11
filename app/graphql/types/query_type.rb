# frozen_string_literal: true

module Types
  QueryType =
    GraphQL::ObjectType.define do
      name 'Query'
      description 'Query root for this schema'
      field :submission, Types::SubmissionType do
        description 'Get a Submission'
        argument :id, types.ID
        permit :admin

        resolve ->(_object, args, _context) { Submission.find(args[:id]) }
      end

      connection :submissions, Types::SubmissionType.define_connection do
        description 'Filter all submission'

        argument :ids,
                 types[types.ID],
                 'Get all submissions with these IDs',
                 permit: :admin
        argument :user_id,
                 types[types.ID],
                 'Only get submission by this user_id',
                 prepare: lambda { |obj, context|
                   is_same_as_user = obj == context[:current_user]
                   if !is_same_as_user &&
                        !context[:current_user_roles].include?(:admin)
                     GraphQL::ExecutionError.new(
                       'Only Admins can use the user_id for another user.'
                     )
                   end
                   obj
                 }

        argument :completed,
                 types.Boolean,
                 'If present return either completed or not completed submissions'

        resolve lambda { |_object, args, context|
                  get_all_submissions = !args[:ids] && !args[:user_id]
                  if !get_all_submissions &&
                       !context[:current_user_roles].include?(:admin)
                    return(
                      GraphQL::ExecutionError.new(
                        'Only Admins can look at all submissions.'
                      )
                    )
                  end

                  submissions = Submission.order(id: :desc)
                  submissions =
                    if args[:ids]
                      submissions.where(id: args[:ids])
                    elsif args[:user_id]
                      submissions.where(user_id: args[:user_id])
                    else
                      submissions
                    end

                  if args.key?('completed')
                    submissions =
                      if args[:completed]
                        submissions.completed
                      else
                        submissions.draft
                      end
                  end

                  submissions
                }
      end
    end
end
