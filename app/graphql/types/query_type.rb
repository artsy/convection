# frozen_string_literal: true

module Types
  class QueryType < GraphQL::Schema::Object
    field :submission, SubmissionType, null: true do
      description 'Get a Submission'
      argument :id, ID, required: false
    end

    def submission(arguments)
      query_options = { arguments: arguments, context: context, object: object }
      resolver = SubmissionResolver.new(query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end

    field :submissions, SubmissionType.connection_type, null: true do
      description 'Filter all submission'

      argument :ids, [ID], required: false do
        description 'Get all submissions with these IDs'
      end

      argument :user_id, [ID], required: false do
        description 'Get all submissions with these user IDs'
      end

      argument :completed, Boolean, required: false do
        description 'If present return either completed or not completed submissions'
      end
    end

    def submissions(arguments)
      query_options = { arguments: arguments, context: context, object: object }
      resolver = SubmissionsResolver.new(query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
