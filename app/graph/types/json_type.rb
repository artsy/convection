module Types
  JsonType = GraphQL::ScalarType.define do
    name 'JSON'
    coerce_input ->(x) { JSON.parse(x) }
    coerce_result ->(x) { JSON.dump(x) }
  end
end
