# frozen_string_literal: true

module Extensions
  class NilableFieldExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, arguments:, **_rest)
      begin
        yield(object, arguments, nil)
      rescue StandardError
        nil
      end
    end
  end
end
