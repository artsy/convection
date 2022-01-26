# frozen_string_literal: true

class AddAssetToSubmissionResolver < BaseResolver
  include SubmissionableResolver

  def run
    raise(GraphQL::ExecutionError, 'Submission Not Found') unless submission

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, 'Submission Not Found')
    end

    @arguments[:asset_type] ||= 'image'

    asset = submission.assets.create!(@arguments.except(:session_id))
    SubmissionService.notify_user(submission.id) if submission.submitted?

    { asset: asset }
  end

  private

  def submission_id
    @arguments[:submission_id]
  end

  def external_submission_id
    @arguments[:external_submission_id]
  end
end
