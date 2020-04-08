# frozen_string_literal: true

module Types
  class SubmissionEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::SubmissionType)
  end

  class SubmissionConnectionType < Types::Pagination::PageableConnection
    edge_type(Types::SubmissionEdgeType)
  end
end
