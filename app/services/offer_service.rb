class OfferService
  class << self
    def update_offer(offer, params)
      offer.assign_attributes(params)
      offer.save!
    end

    def create_offer(params)
      submission = Submission.find(params[:submission_id])
      partner = Partner.find(params[:partner_id])
      partner_submission = PartnerSubmission.find_or_create_by!(submission_id: submission.id, partner_id: partner.id)
      offer = partner_submission.offers.new(state: 'draft', offer_type: params[:offer_type])
      offer.save!
    end
  end
end
