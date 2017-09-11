RootSchema = GraphQL::Schema.define do
  query Queries::Root
  mutation Mutations::Root

  max_depth 5
end
