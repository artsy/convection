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

  InvalidSortError = GraphQL::ExecutionError.new('Invalid sort column.')

  def valid?
    @error = compute_error
    @error.nil?
  end

  def run
    base_submissions.where(conditions).order(sort_order)
  end

  private

  def compute_error
    if not_allowed_ids?
      BadArgumentError
    elsif not_allowed_all_submissions?
      AllSubmissionsError
    elsif user_mismatch?
      UserMismatchError
    elsif invalid_sort?
      InvalidSortError
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

  def not_allowed_ids?
    return false if admin?

    @arguments.key?(:ids)
  end

  def not_allowed_all_submissions?
    return false if admin?

    return_all_submissions? && !partner?
  end

  def return_all_submissions?
    submission_ids.empty? && user_ids.empty?
  end

  def user_mismatch?
    return false if admin?
    return false unless @arguments.key(:user_id)

    user_ids != [@context[:current_user]]
  end

  def invalid_sort?
    return false if @arguments[:sort].blank?

    column_name = @arguments[:sort].keys.first
    !Submission.column_names.include?(column_name)
  end

  def sort_order
    default_sort = { id: :desc }
    return default_sort unless @arguments[:sort]

    @arguments[:sort]
  end
end
