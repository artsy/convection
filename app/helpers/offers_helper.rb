module OffersHelper
  def reviewed_byline(offer)
    if offer.accepted?
      "Accepted by #{offer.recorded_by_user.try(:name)}."
    elsif offer.rejected?
      [
        "Rejected by #{offer.recorded_by_user.try(:name)}. #{offer.rejection_reason}",
        offer.rejection_note
      ].compact.reject(&:blank?).join(': ').strip
    elsif offer.lapsed?
      'Offer lapsed.'
    end
  end
end
