# frozen_string_literal: true

class SubmissionResolver < BaseResolver
  def valid?
    unless admin?
      bad_argument_error =
        GraphQL::ExecutionError.new("Can't access submission")
      @error = bad_argument_error
    end

    admin?
  end

  def run
    Submission.find(@arguments[:id])
  rescue ActiveRecord::RecordNotFound
    raise GraphQL::ExecutionError, 'Submission not found'
  end
end
