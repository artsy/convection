# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField

    def self.nilable_field(*args, **kwargs, &block)
      field(*args, nilable_field: true, **kwargs, &block)
    end
  end
end
