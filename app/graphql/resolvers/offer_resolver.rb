# frozen_string_literal: true

class OfferResolver < BaseResolver
  BadArgumentError = GraphQL::ExecutionError.new("Can't access offer")

  def valid?
    @error = compute_error
    @error.nil?
  end

  def run
    partner.offers.find(@arguments[:id])
  rescue ActiveRecord::RecordNotFound
    raise GraphQL::ExecutionError, 'Offer not found'
  end

  private

  def compute_error
    return BadArgumentError unless admin? || partner?
  end

  def partner
    Partner.find_by(gravity_partner_id: @arguments[:gravity_partner_id])
  end
end
