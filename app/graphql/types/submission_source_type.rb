# frozen_string_literal: true

module Types
  class SubmissionSourceType < Types::BaseEnum
    Submission::SOURCES.map do |source|
      value(source.upcase, nil, value: source)
    end
  end
end
