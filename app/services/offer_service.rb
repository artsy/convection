class OfferService
  class OfferError < StandardError; end

  class << self
    def update_offer(offer, current_user = nil, params = {})
      offer.assign_attributes(params)
      update_offer_state(offer, current_user) if offer.state_changed?
      offer.save!
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

    def update_offer_state(offer, current_user)
      case offer.state
      when 'sent' then send_offer!(offer, current_user)
      when 'accepted' then accept!(offer, current_user)
      when 'rejected' then reject!(offer, current_user)
      end
    end

    def send_offer!(offer, current_user)
      delay.deliver_offer(offer.id, current_user)
    end

    def accept!(offer, current_user)
      offer.update_attributes!(accepted_by: current_user, accepted_at: Time.now.utc)
      offer.submission.update_attributes!(consigned_partner_submission: offer.partner_submission)
      PartnerSubmissionService.mark_consignment(offer)
      delay.deliver_acceptance_notification(offer.id)
    end

    def reject!(offer, current_user)
      offer.update_attributes!(rejected_by: current_user, rejected_at: Time.now.utc)
      delay.deliver_rejection_notification(offer.id)
    end

    private

    def deliver_acceptance_notification(offer_id)
      offer = Offer.find(offer_id)
      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      PartnerMailer.offer_acceptance_notification(
        offer: offer,
        artist: artist
      ).deliver_now
    end

    def deliver_rejection_notification(offer_id)
      offer = Offer.find(offer_id)
      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      PartnerMailer.offer_rejection_notification(
        offer: offer,
        artist: artist
      ).deliver_now
    end

    def deliver_offer(offer_id, current_user)
      offer = Offer.find(offer_id)
      return if offer.sent_at

      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      UserMailer.offer(
        offer: offer,
        artist: artist
      ).deliver_now

      offer.update_attributes!(sent_at: Time.now.utc, sent_by: current_user)
    end
  end
end
