# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  include SubmissionableResolver

  def run
    raise GraphQL::ExecutionError, 'Submission Not Found' unless submission

    unless draft_in_progress?(submission, @arguments) || admin? || partner?
      raise GraphQL::ExecutionError, 'Submission Not Found'
    end

    submission
  end

  def draft_in_progress?(submission, arguments)
    submission.draft? && matching_user(submission, arguments&.[](:session_id))
  end
end
