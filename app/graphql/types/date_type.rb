# frozen_string_literal: true

module Types
  class DateType < Types::BaseScalar
    description "Date in YYYY-MM-DD format"
    DATE_FORMAT = "%Y-%m-%d"

    def self.coerce_input(input_value, _context)
      # Parse the incoming object into a DateTime
      Date.strptime(input_value, DATE_FORMAT)
    end

    def self.coerce_result(ruby_value, _context)
      # It's transported as a string, so stringify it
      ruby_value.strftime(DATE_FORMAT)
    end
  end
end
