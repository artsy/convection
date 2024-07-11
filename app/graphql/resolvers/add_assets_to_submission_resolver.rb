# frozen_string_literal: true

class AddAssetsToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, "Submission Not Found")
    end

    assets = create_assets(
      gemini_tokens: @arguments[:gemini_tokens],
      sources: @arguments[:sources],
      asset_type: @arguments[:asset_type]
    )
    SubmissionService.notify_user(submission.id) if submission.submitted?

    {assets: assets}
  end

  def create_assets(asset_type:, gemini_tokens: [], sources: {})
    (gemini_tokens || []).map do |token|
      submission.assets.create(
        asset_type: asset_type || "image",
        gemini_token: token
      )
    end

    if sources
      (sources[:keys] || []).map.with_index do |key, index|
        submission.assets.create(
          asset_type: asset_type || "additional_file",
          s3_path: key,
          s3_bucket: sources[:buckets][index]
        )
      end
    end

    submission.assets
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
