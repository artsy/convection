# frozen_string_literal: true

module Types
  class SubmissionSortType < SortType
    generate_values(Submission.column_names)
  end
end
