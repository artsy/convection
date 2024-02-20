# frozen_string_literal: true

module OffersHelper
  include ApplicationHelper
  include GraphqlHelper
  def reviewed_byline(offer)
    if offer.rejected?
      [
          "Rejected by #{offer.rejected_by_user.try(:name)}. #{
            offer.rejection_reason
          }",
          offer.rejection_note
        ].compact
        .reject(&:blank?)
        .join(": ")
        .strip
    elsif offer.lapsed?
      "Offer lapsed."
    end
  end

  def display_fields(offer)
    {
      "Estimate" => estimate_display(offer),
      "Starting Bid / Suggested Reserve price" => offer.starting_bid_display,
      "Price" => price_display(offer.currency, offer.price_cents),
      "Sale Period" => sale_period_display(offer),
      "Sale Date" => sale_date_display(offer),
      "Sale Name" => offer.sale_name,
      "Sale Location" => offer.sale_location,
      "Deadline" => offer.deadline_to_consign,
      "Commission" => commission_display(offer),
      "Shipping" => offer.shipping_info,
      "Photography" => offer.photography_info,
      "Insurance" => offer.insurance_info,
      "Other fees" => offer.other_fees_info
    }.select { |_key, value| value.present? }
  end

  def formatted_offer_type(offer)
    case offer.offer_type
    when Offer::AUCTION_CONSIGNMENT
      offer.offer_type.capitalize
    when Offer::PURCHASE
      "Outright purchase"
    when Offer::RETAIL
      "Private Sale: Retail Price"
    when Offer::NET_PRICE
      "Private Sale: Net Price"
    end
  end

  def offer_type_description(offer)
    case offer.offer_type
    when Offer::AUCTION_CONSIGNMENT
      "This work will be offered in an auction. The work will sell if bidding meets the " \
        "minimum selling price that you and the auction house have agreed to. Please note " \
        "that the minimum selling price generally cannot be higher than the suggested low " \
        "estimate. You are responsible for shipping the work to the auction house unless " \
        "otherwise stated in the notes."
    when Offer::PURCHASE
      "The work will be purchased directly from you by the partner for the specified price."
    when Offer::RETAIL, Offer::NET_PRICE
      "This work will be offered privately to a small group of collectors that the partner has " \
        "relationships with. The work will sell if a collector agrees to your price."
    end
  end

  def estimate_display(offer)
    return unless offer

    currency = Money::Currency.new(offer.currency)
    estimate =
      [offer.low_estimate_cents, offer.high_estimate_cents].compact
        .map do |amt|
        number_with_delimiter(amt / currency.subunit_to_unit.round)
      end.join(" - ")
    "#{offer.currency} #{currency.symbol}#{estimate}" if estimate.present?
  end

  def sale_period_display(offer)
    unless offer.sale_period_start.present? || offer.sale_period_end.present?
      return
    end

    if offer.sale_period_start.present?
      if offer.sale_period_end.present?
        "#{formatted_date_offer(offer.sale_period_start)} - #{
          formatted_date_offer(offer.sale_period_end)
        }"
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

    "#{(offer.commission_percent * 100).round(2)}%"
  end

  def formatted_date_offer(date)
    date.strftime("%b %-d, %Y")
  end

  def offer_artist(offer)
    offers_artists[offer.submission&.artist_id]
  end
end
