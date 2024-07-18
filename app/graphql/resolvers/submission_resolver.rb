# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless matching_user(submission, @arguments&.[](:session_id)) || admin? || partner?
      raise GraphQL::ExecutionError, "Submission Not Found"
    end

    submission
  end
end
