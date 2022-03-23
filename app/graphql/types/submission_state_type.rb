# frozen_string_literal: true

module Types
  class SubmissionStateType < Types::BaseEnum
    description 'Enum with all available submission states'

    Submission::STATES.map { |source| value(source.upcase, nil, value: source) }
  end
end
