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

    def create_offer(
      submission_id, partner_id, offer_params = {}, current_user = nil
    )
      submission = Submission.find(submission_id)
      if [Submission::DRAFT, Submission::REJECTED].include? submission.state
        raise OfferError, 'Invalid submission state for offer creation'
      end

      if submission.state == Submission::SUBMITTED
        submission.update!(
          state: Submission::APPROVED,
          approved_by: current_user,
          approved_at: Time.now.utc
        )
      end
      partner = Partner.find(partner_id)
      partner_submission =
        PartnerSubmission.find_or_create_by!(
          submission_id: submission.id, partner_id: partner.id
        )
      if partner_submission.notified_at.blank?
        partner_submission.update!(notified_at: Time.now.utc)
      end
      offer =
        partner_submission.offers.new(
          offer_params.merge(state: 'draft', created_by_id: current_user)
        )
      offer.save!
      offer
    rescue ActiveRecord::RecordNotFound => e
      raise OfferError, e.message
    end

    def update_offer_state(offer, current_user)
      case offer.state
      when 'sent'
        send_offer!(offer, current_user)
      when 'review'
        review!(offer)
      when 'consigned'
        consign!(offer)
      when 'rejected'
        reject!(offer, current_user)
      end
    end

    def send_offer!(offer, current_user)
      delay.deliver_offer(offer.id, current_user)
    end

    def consign!(offer)
      unless offer.submission.state == Submission::APPROVED
        raise OfferError,
              'Cannot complete consignment on non-approved submission'
      end

      offer.update!(consigned_at: Time.now.utc)
      offer.submission.update!(
        consigned_partner_submission: offer.partner_submission
      )

      offer.partner_submission.update!(
        accepted_offer: offer,
        partner_commission_percent: offer.commission_percent,
        state: 'open'
      )
    end

    def review!(offer)
      offer.update!(review_started_at: Time.now.utc)
      delay.deliver_introduction(offer.id)
    end

    def reject!(offer, current_user)
      offer.update!(rejected_by: current_user, rejected_at: Time.now.utc)
      delay.deliver_rejection_notification(offer.id)
    end

    private

    def deliver_introduction(offer_id)
      offer = Offer.find(offer_id)
      partner_emails(offer).each do |email|
        delay.deliver_partner_contact_introduction(offer.id, email)
      end
    end

    def deliver_partner_contact_introduction(offer_id, email)
      offer = Offer.find(offer_id)
      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      PartnerMailer.offer_introduction(
        offer: offer, artist: artist, email: email
      )
        .deliver_now
    end

    def deliver_rejection_notification(offer_id)
      offer = Offer.find(offer_id)
      partner_emails(offer).each do |email|
        delay.deliver_partner_contact_rejection(offer.id, email)
      end
    end

    def deliver_partner_contact_rejection(offer_id, email)
      offer = Offer.find(offer_id)
      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      PartnerMailer.offer_rejection(offer: offer, artist: artist, email: email)
        .deliver_now
    end

    def deliver_offer(offer_id, current_user)
      offer = Offer.find(offer_id)
      return if offer.sent_at

      user = Gravity.client.user(id: offer.submission.user.gravity_user_id)._get
      user_detail = user.user_detail._get
      raise 'User lacks email.' if user_detail.email.blank?

      artist = Gravity.client.artist(id: offer.submission.artist_id)._get

      UserMailer.offer(
        offer: offer, artist: artist, user: user, user_detail: user_detail
      )
        .deliver_now

      offer.update!(sent_at: Time.now.utc, sent_by: current_user)
    end
  end

  def self.partner_emails(offer)
    if offer.override_email.present?
      [offer.override_email]
    else
      PartnerService.fetch_partner_contacts!(offer.partner)
    end
  end
end
