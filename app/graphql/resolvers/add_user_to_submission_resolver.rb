# frozen_string_literal: true

class AddUserToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    # early no-op if already claimed by the current user
    if submitted_by_current_user?(submission)
      return {consignment_submission: submission}
    end

    if submission.user_id
      raise(GraphQL::ExecutionError, "Submission already has a user")
    end

    if submission.state != Submission::DRAFT
      raise(GraphQL::ExecutionError, "Submission must be in a draft state to claim")
    end

    SubmissionService.add_user_to_submission(
      submission,
      @context[:current_user],
      @context[:jwt_token]
    )

    {consignment_submission: submission}
  end

  def submission
    @submission ||= Submission.find_by(uuid: submission_id)
  end
end
