# frozen_string_literal: true

module Types
  class OfferEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::OfferType)
  end

  class OfferConnectionType < GraphQL::PageCursorConnection
    edge_type(Types::OfferEdgeType)
  end
end
