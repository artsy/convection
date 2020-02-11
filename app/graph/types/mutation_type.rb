module Types
  MutationType =
    GraphQL::ObjectType.define do
      name 'Mutation'
      description 'Mutation root for this schema'

      field :createConsignmentSubmission,
            Mutations::CreateConsignmentSubmission::Definition.return_type do
        permit :user
        argument :input,
                 Mutations::CreateConsignmentSubmission::Definition.input_type

        resolve lambda { |obj, args, context|
                  Mutations::CreateConsignmentSubmission.resolve(
                    obj,
                    args,
                    context
                  )
                }
      end

      field :updateConsignmentSubmission,
            Mutations::UpdateConsignmentSubmission::Definition.return_type do
        permit :user
        argument :input,
                 Mutations::UpdateConsignmentSubmission::Definition.input_type

        resolve lambda { |obj, args, context|
                  Mutations::UpdateConsignmentSubmission.resolve(
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
