# frozen_string_literal: true

module Types
  class SortType < Types::BaseEnum
    DIRECTIONS = %w[asc desc].freeze

    def self.generate_values(columns)
      columns.sort.each do |column_name|
        asc_value, desc_value =
          DIRECTIONS.map do |direction|
            [column_name, direction].join('_').upcase
          end

        value asc_value, "sort by #{column_name} in ascending order"
        value desc_value, "sort by #{column_name} in descending order"
      end
    end

    def self.prepare
      lambda do |sort, _context|
        return unless sort

        match_data = sort.downcase.match(/(.*)_(asc|desc)/)
        column_name, direction = match_data.captures
        { column_name => direction }
      end
    end
  end
end
