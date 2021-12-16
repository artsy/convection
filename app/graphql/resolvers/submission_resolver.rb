# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  def run
    submission = Submission.find_by(id: @arguments[:id])

    unless submission
      raise GraphQL::ExecutionError, 'Submission from ID Not Found'
    end

    unless draft_in_progress?(submission, @arguments) || admin? || partner?
      raise GraphQL::ExecutionError, 'Submission Not Found'
    end

    submission
  end

  def draft_in_progress?(submission, arguments)
    submission.draft? && matching_user(submission, arguments&.[](:session_id))
  end
end
