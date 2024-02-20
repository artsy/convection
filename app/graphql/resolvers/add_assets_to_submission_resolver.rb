# frozen_string_literal: true

class AddAssetsToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, "Submission Not Found")
    end

    assets = create_assets(@arguments[:gemini_tokens], @arguments[:asset_type])
    SubmissionService.notify_user(submission.id) if submission.submitted?

    {assets: assets}
  end

  def create_assets(gemini_tokens, asset_type)
    gemini_tokens.map do |token|
      submission.assets.create(
        asset_type: asset_type || "image",
        gemini_token: token
      )
    end
  end

  private

  # overwrites Resolvers::Submissionable
  def submission_id
    @arguments[:submission_id]
  end

  # overwrites Resolvers::Submissionable
  def external_submission_id
    @arguments[:external_submission_id]
  end
end
