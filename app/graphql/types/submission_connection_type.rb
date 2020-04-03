# frozen_string_literal: true

module Types
  class SubmissionEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::SubmissionType)
  end

  class PageableConnection < GraphQL::Types::Relay::BaseConnection
    field :hicks, String, null: true
  end

  class SubmissionConnectionType < Types::PageableConnection
    edge_type(Types::SubmissionEdgeType)
  end
end
