# frozen_string_literal: true

module Extensions
  class NilableFieldExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, arguments:, **_rest)
      yield(object, arguments, nil)
    rescue
      nil
    end
  end
end
