# frozen_string_literal: true

class OfferResponseService
  class OfferResponseError < StandardError; end

  def self.create_offer_response(offer_id, offer_response_params = {})
    offer = Offer.find(offer_id)

    offer_response = offer.offer_responses.new(offer_response_params)
    offer_response.save!
    offer_response
  rescue ActiveRecord::RecordNotFound => e
    raise OfferResponseError, e.message
  end
end
