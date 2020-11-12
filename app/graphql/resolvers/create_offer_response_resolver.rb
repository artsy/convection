# frozen_string_literal: true

class CreateOfferResponseResolver < BaseResolver
  def valid?
    return true if user?

    bad_argument_error =
      GraphQL::ExecutionError.new("Can't access createConsignmentOfferResponse")
    @error = bad_argument_error
    false
  end

  def run
    offer = Offer.find(offer_id)
    matching_user =
      offer.submission&.user&.gravity_user_id == @context[:current_user]

    raise GraphQL::ExecutionError, 'Offer not found' unless matching_user

    offer_response = offer.offer_responses.create!(offer_response_attributes)

    { consignment_offer_response: offer_response }
  rescue ActiveRecord::RecordNotFound
    raise GraphQL::ExecutionError, 'Offer not found'
  rescue ActiveRecord::RecordInvalid => e
    raise GraphQL::ExecutionError, e.message
  end

  private

  def offer_id
    @arguments[:offer_id]
  end

  def offer_response_attributes
    @arguments.except(:offer_id)
  end
end
