# frozen_string_literal: true

module Types
  class ConsignmentSortType < SortType
    generate_values(PartnerSubmission.column_names)
  end
end
