# frozen_string_literal: true

class ConvectionSchema < GraphQL::Schema
  max_depth 13
  max_complexity 300
  default_max_page_size 20

  query(Types::QueryType)

  use GraphQL::Pagination::Connections
end
