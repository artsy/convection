module Types
  DateType = GraphQL::ScalarType.define do
    name 'Date'
    description 'Date type'

    coerce_input ->(value) { Time.at(Float(value)) }
    coerce_result ->(value) { value.to_f }
  end
end
