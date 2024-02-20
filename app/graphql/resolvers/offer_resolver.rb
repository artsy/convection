# frozen_string_literal: true

class OfferResolver < BaseResolver
  BadArgumentError = GraphQL::ExecutionError.new("Can't access offer")

  def valid?
    @error = compute_error
    @error.nil?
  end

  def run
    if partner? || admin? && partner.present?
      return partner.offers.find(@arguments[:id])
    end

    offer = Offer.find(@arguments[:id])
    validate_user(offer)
    validate_offer_state(offer)
    offer
  rescue ActiveRecord::RecordNotFound
    raise GraphQL::ExecutionError, "Offer not found"
  end

  private

  def compute_error
    return BadArgumentError unless admin? || partner? || user?
  end

  def validate_user(offer)
    matching_user =
      offer.submission&.user&.gravity_user_id == @context[:current_user]
    return if matching_user || admin?

    raise(GraphQL::ExecutionError, "Offer not found")
  end

  def validate_offer_state(offer)
    return true if admin?
    return if offer.state != Offer::DRAFT

    raise(GraphQL::ExecutionError, "Offer not found")
  end

  def partner
    Partner.find_by(gravity_partner_id: @arguments[:gravity_partner_id])
  end
end
