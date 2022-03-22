# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless draft_in_progress?(submission, @arguments) ||
             matching_email(submission, arguments&.[](:user_email)) || admin? ||
             partner?
      raise GraphQL::ExecutionError, 'Submission Not Found'
    end

    submission
  end

  def draft_in_progress?(submission, arguments)
    submission.draft? && matching_user(submission, arguments&.[](:session_id))
  end
end
