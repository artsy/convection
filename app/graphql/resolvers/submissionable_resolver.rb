# TODO: docs

module SubmissionableResolver
  IdsNotPassed =
    GraphQL::ExecutionError.new('Neither id nor externalId have been passed.')

  def submission
    @submission ||=
      Submission.find_by(id: submission_id) ||
        Submission.find_by(external_id: external_submission_id)
  end

  def valid?
    @error = compute_error
    @error.nil?
  end

  private

  def submission_id
    @arguments[:id]
  end

  def external_submission_id
    @arguments[:external_id]
  end

  def compute_error
    return IdsNotPassed unless ids_passed?
  end

  def ids_passed?
    submission_id.present? || external_submission_id.present?
  end
end
