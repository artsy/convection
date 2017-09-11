module Types
  DateType = GraphQL::ScalarType.define do
    name 'Date'
    description 'Date type'

    coerce_input ->(value, _ctx) { Date.new(value) }
    coerce_result ->(value, _ctx) { value.to_f }
  end
end
