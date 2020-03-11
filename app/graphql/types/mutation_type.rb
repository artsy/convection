# frozen_string_literal: true

module Types
  MutationType =
    GraphQL::ObjectType.define do
      name 'Mutation'
      description 'Mutation root for this schema'

      field :createConsignmentSubmission,
            Mutations::CreateSubmissionMutation::Definition.return_type do
        permit :user
        argument :input,
                 Mutations::CreateSubmissionMutation::Definition.input_type

        resolve lambda { |obj, args, context|
                  Mutations::CreateSubmissionMutation.resolve(
                    obj,
                    args,
                    context
                  )
                }
      end

      field :updateConsignmentSubmission,
            Mutations::UpdateSubmissionMutation::Definition.return_type do
        permit :user
        argument :input,
                 Mutations::UpdateSubmissionMutation::Definition.input_type

        resolve lambda { |obj, args, context|
                  Mutations::UpdateSubmissionMutation.resolve(
                    obj,
                    args,
                    context
                  )
                }
      end

      field :addAssetToConsignmentSubmission,
            Mutations::AddAssetToConsignmentSubmission::Definition
              .return_type do
        description 'Create an asset'
        argument :input,
                 Mutations::AddAssetToConsignmentSubmission::Definition
                   .input_type

        resolve lambda { |obj, args, context|
                  Mutations::AddAssetToConsignmentSubmission.resolve(
                    obj,
                    args,
                    context
                  )
                }
      end
    end
end
