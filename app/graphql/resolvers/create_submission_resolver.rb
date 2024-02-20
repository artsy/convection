# frozen_string_literal: true

class CreateSubmissionResolver < BaseResolver
  def run
    submission =
      SubmissionService.create_submission(
        @arguments,
        @context[:current_user],
        is_convection: false
      )

    {consignment_submission: submission}
  end
end
