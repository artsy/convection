module Types
  JsonType = GraphQL::ScalarType.define do
    name 'JSON'
    coerce_input ->(x, _ctx) { JSON.parse(x) }
    coerce_result ->(x, _ctx) { JSON.dump(x) }
  end
end
