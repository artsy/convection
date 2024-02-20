# frozen_string_literal: true

class CreateOfferResolver < BaseResolver
  def valid?
    return true if admin? || trusted_application?

    bad_argument_error =
      GraphQL::ExecutionError.new("Can't access createConsignmentOffer")
    @error = bad_argument_error
    false
  end

  def run
    offer =
      OfferService.create_offer(submission_id, partner_id, offer_attributes)

    {consignment_offer: offer}
  end

  private

  def submission_id
    @arguments[:submission_id]
  end

  def partner_id
    gravity_partner_id = @arguments[:gravity_partner_id]
    partner = Partner.find_by(gravity_partner_id: gravity_partner_id)
    partner.id
  end

  def offer_attributes
    @arguments.except(:submission_id, :gravity_partner_id)
  end
end
