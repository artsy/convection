# frozen_string_literal: true

class ConsignmentsResolver < BaseResolver
  BadArgumentError = GraphQL::ExecutionError.new("Can't find partner.")
  InvalidSortError = GraphQL::ExecutionError.new("Invalid sort column.")

  def valid?
    @error = compute_error
    @error.nil?
  end

  def run
    partner.partner_submissions.where(conditions).order(sort_order)
  end

  private

  def compute_error
    return BadArgumentError unless admin? || partner?

    InvalidSortError if invalid_sort?
  end

  def invalid_sort?
    return false if @arguments[:sort].blank?

    column_name = @arguments[:sort].keys.first
    PartnerSubmission.column_names.exclude?(column_name)
  end

  def partner
    Partner.find_by(gravity_partner_id: @arguments[:gravity_partner_id])
  end

  def conditions
    {state: ["sold", "bought in"]}
  end

  def sort_order
    default_sort = {id: :desc}
    return default_sort unless @arguments[:sort]

    @arguments[:sort]
  end
end
