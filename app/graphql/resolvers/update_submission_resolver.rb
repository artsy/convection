# frozen_string_literal: true

class UpdateSubmissionResolver < BaseResolver
  def run
    submission = Submission.find_by(id: @arguments[:id])

    unless submission
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
    end

    unless matching_user(submission) || admin?
      raise(GraphQL::ExecutionError, 'Submission Not Found')
    end

    # I'm not clear if this is needed or not - there are no tests for it so I'm
    # suspicious that it's stale.
    #
    # params.delete('dimensions_metric')

    SubmissionService.update_submission(
      submission,
      @arguments.except(:id, :session_id)
    )

    { consignment_submission: submission }
  end

  def matching_user(submission)
    submission.user&.gravity_user_id == @context&.[](:current_user) ||
      submission.user&.session_id == @arguments&.[](:session_id)
  end
end
