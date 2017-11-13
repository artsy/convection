RootSchema = GraphQL::Schema.define do
  query Types::QueryType
  mutation Mutations::Root

  max_depth 5
end
