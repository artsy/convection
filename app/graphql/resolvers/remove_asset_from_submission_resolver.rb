# frozen_string_literal: true

class RemoveAssetFromSubmissionResolver < BaseResolver
  def run
    asset = Asset.find_by(id: @arguments[:asset_id])
    raise(GraphQL::ExecutionError, 'Asset Not Found') unless asset

    submission = asset.submission
    raise(GraphQL::ExecutionError, 'Submission Not Found') unless submission

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, 'Submission Not Found')
    end

    asset.destroy!

    SubmissionService.notify_user(submission.id) if submission.submitted?

    { asset: asset }
  end
end
