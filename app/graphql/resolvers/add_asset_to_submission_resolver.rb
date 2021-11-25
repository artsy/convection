# frozen_string_literal: true

class AddAssetToSubmissionResolver < BaseResolver
  def valid?
    true
  end

  def run
    submission = Submission.find_by(id: @arguments[:submission_id])
    unless submission
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
    end

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, 'Submission Not Found')
    end

    @arguments[:asset_type] ||= 'image'

    asset = submission.assets.create!(@arguments)
    SubmissionService.notify_user(submission.id) if submission.submitted?

    { asset: asset }
  end
end
