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

  def display_fields(offer)
    {
      'Offer type' => offer.offer_type.capitalize,
      'Estimate' => estimate_display(offer),
      'Price' => price_display(offer),
      'Sale Period' => sale_period_display(offer),
      'Sale Date' => sale_date_display(offer),
      'Sale Name' => offer.sale_name,
      'Commission' => commission_display(offer),
      'Shipping' => shipping_display(offer),
      'Photography' => photography_display(offer),
      'Insurance' => insurance_display(offer),
      'Other fees' => other_fees_display(offer)
    }.compact.reject { |_key, value| value.empty? }
  end

  def estimate_display(offer)
    currency = Money::Currency.new(offer.currency)
    estimate = [
      offer.low_estimate_cents,
      offer.high_estimate_cents
    ].compact.map { |amt| (amt / currency.subunit_to_unit).round }.join(' - ')
    "#{offer.currency} #{currency.symbol}#{estimate}" if estimate.present?
  end

  def price_display(offer)
    return if offer.price_cents.blank?
    "#{offer.currency} #{Money.new(offer.price_cents, offer.currency).format(no_cents: true)}"
  end

  def sale_period_display(offer)
    return unless offer.sale_period_start.present? || offer.sale_period_end.present?
    if offer.sale_period_start.present?
      if offer.sale_period_end.present?
        "#{formatted_date_offer(offer.sale_period_start)} - #{formatted_date_offer(offer.sale_period_end)}"
      else
        "Starts #{formatted_date_offer(offer.sale_period_start)}"
      end
    else
      "Ends #{formatted_date_offer(offer.sale_period_end)}"
    end
  end

  def sale_date_display(offer)
    return if offer.sale_date.blank?
    formatted_date_offer(offer.sale_date)
  end

  def commission_display(offer)
    return if offer.commission_percent.blank?
    "#{offer.commission_percent * 100}%"
  end

  def shipping_display(offer)
    return if offer.shipping_cents.blank?
    "#{offer.currency} #{Money.new(offer.shipping_cents, offer.currency).format}"
  end

  def photography_display(offer)
    return if offer.photography_cents.blank?
    "#{offer.currency} #{Money.new(offer.photography_cents, offer.currency).format}"
  end

  def insurance_display(offer)
    return unless offer.insurance_cents.present? || offer.insurance_percent.present?
    if offer.insurance_cents.present?
      "#{offer.currency} #{Money.new(offer.insurance_cents, offer.currency).format}"
    else
      "#{offer.insurance_percent * 100}%"
    end
  end

  def other_fees_display(offer)
    return unless offer.other_fees_cents.present? || offer.other_fees_percent.present?
    if offer.other_fees_cents.present?
      "#{offer.currency} #{Money.new(offer.other_fees_cents, offer.currency).format}"
    else
      "#{offer.other_fees_percent * 100}%"
    end
  end

  def formatted_date_offer(date)
    date.strftime('%b %-d, %Y') # rubocop:disable Style/FormatStringToken
  end
end
