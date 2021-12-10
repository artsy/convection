# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  def valid?
    true
  end

  def run
    submission = Submission.find_by(id: @arguments[:id])

    unless submission
      raise GraphQL::ExecutionError, 'Submission from ID Not Found'
    end

    unless matching_user(submission, @arguments&.[](:session_id)) || admin? ||
             partner?
      raise GraphQL::ExecutionError, 'Submission Not Found'
    end

    submission
  end
end
