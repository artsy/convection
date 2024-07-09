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
      s3_paths: @arguments[:s3_paths],
      s3_buckets: @arguments[:s3_buckets],
      asset_type: @arguments[:asset_type]
    )
    SubmissionService.notify_user(submission.id) if submission.submitted?

    {assets: assets}
  end

  def create_assets(asset_type:, gemini_tokens: [], s3_paths: [], s3_buckets: [])
    (gemini_tokens || []).map do |token|
      submission.assets.create(
        asset_type: asset_type || "image",
        gemini_token: token
      )
    end

    (s3_paths || []).map.with_index do |s3_path, index|
      submission.assets.create(
        asset_type: asset_type || "additional_file",
        s3_path: s3_path,
        s3_bucket: s3_buckets[index]
      )
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
