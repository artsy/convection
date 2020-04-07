# frozen_string_literal: true

class SubmissionsResolver < BaseResolver
  AllSubmissionsError =
    GraphQL::ExecutionError.new(
      'Only Admins and Partners can look at all submissions.'
    )

  UserMismatchError =
    GraphQL::ExecutionError.new(
      'Only Admins can use the user_id for another user.'
    )

  BadArgumentError = GraphQL::ExecutionError.new("Can't access arguments: ids")

  def valid?
    return true if admin?

    @error = compute_error
    @error.nil?
  end

  def run
    base_submissions.where(conditions).order(id: :desc)
  end

  private

  def compute_error
    if @arguments.key?(:ids)
      BadArgumentError
    elsif return_all_submissions? && !partner?
      AllSubmissionsError
    elsif user_mismatch?
      UserMismatchError
    end
  end

  def base_submissions
    @arguments[:available] ? Submission.available : Submission.all
  end

  def conditions
    { id: submission_ids.presence, user_id: user_ids.presence }.compact
  end

  def submission_ids
    @arguments.fetch(:ids, [])
  end

  def user_ids
    @arguments.fetch(:user_id, [])
  end

  def return_all_submissions?
    submission_ids.empty? && user_ids.empty?
  end

  def user_mismatch?
    return false unless @arguments.key(:user_id)

    user_ids != [@context[:current_user]]
  end
end
