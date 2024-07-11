# frozen_string_literal: true

class AddAssetToSubmissionResolver < BaseResolver
  include Resolvers::Submissionable

  def run
    check_submission_presence!

    unless matching_user(submission, @arguments&.[](:session_id)) || admin?
      raise(GraphQL::ExecutionError, "Submission Not Found")
    end

    @arguments[:asset_type] ||= "image"

    asset = submission.assets.create!(asset_params)
    SubmissionService.notify_user(submission.id) if submission.submitted?

    {asset: asset}
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

  def asset_params
    # remove session_id and external_submission_id from arguments
    # and remap source[:bucket] to s3_bucket and source[:key] to s3_path
    @arguments.except(:session_id, :external_submission_id)
      .tap do |params|
        if (source = params.delete(:source))
          params[:s3_bucket] = source[:bucket]
          params[:s3_path] = source[:key]
        end
      end
  end
end
