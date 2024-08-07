# frozen_string_literal: true

class CreateSubmissionResolver < BaseResolver
  def run
    submission =
      SubmissionService.create_submission(
        @arguments,
        @context[:current_user],
        is_convection: false,
        access_token: @context[:jwt_token]
      )

    {consignment_submission: submission}
  end
end
