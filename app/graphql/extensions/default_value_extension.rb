# frozen_string_literal: true

module Extensions
  class DefaultValueExtension < GraphQL::Schema::FieldExtension
    def after_resolve(value:, **_rest)
      value.nil? ? options[:default_value] : value
    end
  end
end
