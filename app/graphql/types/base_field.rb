# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    def initialize(
      *args,
      nilable_field: false,
      default_value: nil,
      **kwargs,
      &block
    )
      super(*args, **kwargs, &block)

      extension(Extensions::NilableFieldExtension) if nilable_field

      unless default_value.nil?
        extension(
          Extensions::DefaultValueExtension,
          default_value: default_value
        )
      end
    end
  end
end
