class OfferService
  class OfferError < StandardError; end

  class << self
    def update_offer(offer, params)
      offer.update_attributes!(params)
      offer
    rescue ActiveRecord::RecordInvalid => e
      raise OfferError, e.message
    end

    def create_offer(submission_id, partner_id, offer_params = {}, current_user = nil)
      submission = Submission.find(submission_id)
      partner = Partner.find(partner_id)
      partner_submission = PartnerSubmission.find_or_create_by!(submission_id: submission.id, partner_id: partner.id)
      offer = partner_submission.offers.new(offer_params.merge(state: 'draft', created_by_id: current_user))
      offer.save!
      offer
    rescue ActiveRecord::RecordNotFound => e
      raise OfferError, e.message
    end
  end
end
