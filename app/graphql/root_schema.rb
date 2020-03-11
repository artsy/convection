# frozen_string_literal: true

GraphQL::Field.accepts_definitions(
  permit: GraphQL::Define.assign_metadata_key(:permit)
)
GraphQL::Argument.accepts_definitions(
  permit: GraphQL::Define.assign_metadata_key(:permit)
)

RootSchema =
  GraphQL::Schema.define do
    query Types::QueryType
    mutation Types::MutationType

    instrument(:field, Util::AuthorizationInstrumentation.new)

    # FIXME: Determine why this was added, as the root submission request returns
    # a depth of 13 (which, either way, seems incorrect).
    # max_depth 5
  end
