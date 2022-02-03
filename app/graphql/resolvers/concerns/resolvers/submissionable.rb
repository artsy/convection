# Include this module in any of Resolvers if you want to perform
# a submission lookup and arguments validation based on
# submission id/external_id.

# Lookup is performed by @arguments[:id]/@arguments[:external_id] by
# default, be can be overwritten be redefining `submission_id` and
# `external_submission_id` in your resolvers.

module Resolvers::Submissionable
  IdsNotPassed =
    GraphQL::ExecutionError.new('Neither id nor externalId have been passed.')

  def submission
    @submission ||=
      Submission.find_by(id: submission_id) ||
        Submission.find_by(uuid: external_submission_id)
  end

  def valid?
    @error = compute_error
    @error.nil?
  end

  def check_submission_presence!
    raise(GraphQL::ExecutionError, 'Submission Not Found') unless submission
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
