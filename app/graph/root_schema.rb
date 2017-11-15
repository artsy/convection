GraphQL::Field.accepts_definitions(permit: GraphQL::Define.assign_metadata_key(:permit))

RootSchema = GraphQL::Schema.define do
  query Types::QueryType
  mutation Mutations::Root
  instrument(:field, Util::AuthorizationInstrumentation.new)
  max_depth 5
end
