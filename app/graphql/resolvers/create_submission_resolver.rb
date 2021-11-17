# frozen_string_literal: true

class CreateSubmissionResolver < BaseResolver
  def valid?
    return true if admin? || trusted_application?

    bad_argument_error =
      GraphQL::ExecutionError.new("Can't access createConsignmentSubmission")
    @error = bad_argument_error
    false
  end

  def run
    submission =
      SubmissionService.create_submission(
        @arguments,
        @context[:current_user],
        is_convection: false
      )
    { consignment_submission: submission }
  end
end
