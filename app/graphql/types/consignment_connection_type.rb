# frozen_string_literal: true

module Types
  class ConsignmentEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::ConsignmentType)
  end

  class ConsignmentConnectionType < GraphQL::PageCursorConnection
    edge_type(Types::ConsignmentEdgeType)
  end
end
