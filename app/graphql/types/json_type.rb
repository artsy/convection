# frozen_string_literal: true

module Types
  class JsonType < Types::BaseScalar
    graphql_name "JSON"

    def self.coerce_input(value, _ctx)
      JSON.parse(value)
    end

    def self.coerce_result(value, _ctx)
      JSON.dump(value)
    end
  end
end
