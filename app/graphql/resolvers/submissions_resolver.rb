# frozen_string_literal: true

class SubmissionsResolver < BaseResolver
  AllSubmissionsError =
    GraphQL::ExecutionError.new('Only Admins can look at all submissions.')

  UserMismatchError =
    GraphQL::ExecutionError.new(
      'Only Admins can use the user_id for another user.'
    )

  def valid?
    return true if admin?

    if @arguments.key?(:ids)
      bad_argument_error =
        GraphQL::ExecutionError.new("Can't access arguments: ids")
      @error = bad_argument_error
      return
    end

    get_all_submissions = @arguments[:ids].empty? && @arguments[:user_id].empty?
    user_mismatch =
      @arguments.key?(:user_id) &&
        @arguments[:user_id] != @context[:current_user]

    if get_all_submissions
      @error = AllSubmissionsError
      return
    end

    if user_mismatch
      @error = UserMismatchError
      return
    end

    @error.nil?
  end

  def run
    base_submissions.where(conditions).order(id: :desc)
  end

  private

  def base_submissions
    @arguments[:available] ? Submission.available : Submission.all
  end

  def conditions
    { id: @arguments[:ids], user_id: @arguments[:user_id] }.compact
  end
end
