# frozen_string_literal: true

module Types
  class DateType < Types::BaseScalar
    description 'Date type'

    def self.coerce_input(value, _ctx)
      Date.new(value)
    end

    def self.coerce_result(value, _ctx)
      value.to_f
    end
  end
end
