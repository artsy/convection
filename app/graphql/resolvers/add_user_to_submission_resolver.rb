# frozen_string_literal: true

class AddUserToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    # check if user's email in Gravity matches the one on the submission
    unless matching_email(submission)
      raise(GraphQL::ExecutionError, "Submission not found for this user")
    end

    #  make sure submission has no user
    if submission.user_id
      raise(GraphQL::ExecutionError, "Submission already has a user")
    end

    SubmissionService.add_user_to_submission(
      submission,
      @context[:current_user],
      @context[:jwt_token]
    )

    # return submission
    {consignment_submission: submission}
  end
end
