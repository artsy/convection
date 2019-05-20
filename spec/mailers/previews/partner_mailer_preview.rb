class PartnerMailerPreview < BasePreview
  def submission_digest_auction
    params = submission_digest_mail_params.merge(partner_name: 'Phillips', partner_type: 'Auction', email: 'foo@foo.com')
    PartnerMailer.submission_digest(params)
  end

  def submission_digest_gallery
    params = submission_digest_mail_params.merge(partner_name: 'Gagosian', partner_type: 'Gallery', email: 'foo@foo.com')
    PartnerMailer.submission_digest(params)
  end

  def offer_introduction
    PartnerMailer.offer_introduction(
      offer: auction_offer,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      email: 'contact1@partner.com'
    )
  end

  def offer_rejection
    PartnerMailer.offer_rejection(
      offer: auction_offer,
      artist: OpenStruct.new(id: 'artist_id', name: 'Andy Warhol'),
      email: 'contact1@partner.com'
    )
  end

  private

  def submission_digest_mail_params
    sub1 = base_submission
    sub2 = base_submission
    sub2.user_id = 'userid2'
    users_to_submissions = [sub1, sub2, base_submission_with_minimum_price].group_by(&:user_id)

    {
      users_to_submissions: users_to_submissions,
      submissions_count: 3
    }
  end
end
