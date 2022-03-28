# frozen_string_literal: true

class AddUserToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    # check if user_email in incoming args matches to the one on the submission
    unless matching_email(submission, @arguments&.[](:user_email))
      raise(GraphQL::ExecutionError, 'Submission Not Found')
    end

    #  make sure submission has no user
    if submission.user_id
      raise(GraphQL::ExecutionError, 'Submission already has a user')
    end

    # create user and assign them to the submission
    user = User.find_or_create_by(gravity_user_id: @context[:current_user])
    user.email = @arguments&.[](:user_email)
    submission.user = user

    # save and return submission
    submission.save!
    { consignment_submission: submission }
  end
end
