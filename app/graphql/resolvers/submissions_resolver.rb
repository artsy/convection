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

  NotAllowedSubmissionsError =
    GraphQL::ExecutionError.new("Can't load other people's submissions.")

  InvalidSortError = GraphQL::ExecutionError.new('Invalid sort column.')

  def valid?
    @error = compute_error
    @error.nil?
  end

  def run
    submissions =
      base_submissions
        .where(conditions)
        .order(sort_order)
        .left_joins(:consigned_partner_submission)

    submissions.map do |submission|
      if admin? || partner? || submission.draft?
        submission
      else
        submission.as_json(properties: :short)
      end
    end
  end

  private

  def compute_error
    if not_allowed_ids?
      NotAllowedSubmissionsError
    elsif not_allowed_all_submissions?
      AllSubmissionsError
    elsif user_mismatch?
      UserMismatchError
    elsif invalid_sort?
      InvalidSortError
    end
  end

  def base_submissions
    submissions = @arguments[:available] ? Submission.available : Submission.all

    if !submission_ids.empty? || !submission_uuids.empty?
      submissions =
        submissions
          .where(id: submission_ids)
          .or(submissions.where(uuid: submission_uuids))
    end

    submissions
  end

  def conditions
    {
      user_id: user_ids.presence,
      category: filter_by_category.presence
    }.compact
  end

  def submission_ids
    @arguments.fetch(:ids, []).select { |id| number?(id) }
  end

  def submission_uuids
    @arguments.fetch(:ids, []).reject { |id| number?(id) }
  end

  def user_ids
    @arguments.fetch(:user_id, [])
  end

  def filter_by_category
    @arguments.fetch(:filter_by_category, [])
  end

  def not_allowed_ids?
    return false if admin? || !@arguments.key?(:ids)
    return true if partner?

    current_user = User.find_by(gravity_user_id: @context[:current_user])

    base_submissions.select(:user_id).distinct.map { |s| s.user_id } != [
      current_user&.id
    ]
  end

  def not_allowed_all_submissions?
    return false if admin?

    return_all_submissions? && !partner?
  end

  def return_all_submissions?
    submission_ids.empty? && submission_uuids.empty? && user_ids.empty?
  end

  def user_mismatch?
    return false if admin?
    return false unless @arguments.key(:user_id)

    user_ids != [@context[:current_user]]
  end

  def invalid_sort?
    return false if @arguments[:sort].blank?

    column_name = @arguments[:sort].keys.first
    Submission.column_names.exclude?(column_name)
  end

  def sort_order
    default_sort = { id: :desc }
    return default_sort unless @arguments[:sort]

    @arguments[:sort]
  end

  def number?(obj)
    obj = obj.to_s unless obj.is_a? String

    /\A[+-]?\d+(\.\d+)?\z/.match(obj)
  end
end
