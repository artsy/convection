# frozen_string_literal: true

class UpdateSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, "Submission Not Found")
    end

    SubmissionService.update_submission(
      submission,
      @arguments.except(:id, :external_id, :session_id),
      current_user: nil,
      is_convection: false,
      access_token: @context[:jwt_token]
    )

    {consignment_submission: submission}
  end

  def valid?
    @error = compute_error
    @error.nil?
  end
end
