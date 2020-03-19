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

    matching_user = submission.user&.gravity_user_id == @context[:current_user]

    unless matching_user || admin?
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
    end

    @arguments[:asset_type] ||= 'image'

    asset = submission.assets.create!(@arguments)
    SubmissionService.notify_user(submission.id) if submission.submitted?

    { asset: asset }
  end
end
