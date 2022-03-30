# frozen_string_literal: true

module Mutations
  class AddUserToSubmissionMutation < Mutations::BaseMutation
    argument :user_email, String, required: true
    argument :id, ID, required: true

    field :consignment_submission, Types::SubmissionType, null: true

    def resolve(arguments)
      resolve_options = {
        arguments: arguments,
        context: context,
        object: object
      }

      resolver = AddUserToSubmissionResolver.new(resolve_options)

      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
