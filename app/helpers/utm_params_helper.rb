module UtmParamsHelper
  def utm_params(source:, campaign:, **args)
    initial = {utm_campaign: campaign, utm_medium: "email", utm_source: source}
    transformed_args = args.each_with_object({}) { |(key, value), obj| obj["utm_#{key}".to_sym] = value }
    initial.merge(transformed_args)
  end

  def offer_utm_params(offer)
    case offer.offer_type
    when Offer::AUCTION_CONSIGNMENT
      utm_params(source: "sendgrid", campaign: "sell", term: "cx", content: "auction-offer")
    when Offer::NET_PRICE
      utm_params(source: "sendgrid", campaign: "sell", term: "cx", content: "net-price-offer")
    when Offer::RETAIL
      utm_params(source: "sendgrid", campaign: "sell", term: "cx", content: "retail-offer")
    when Offer::PURCHASE
      utm_params(source: "sendgrid", campaign: "sell", term: "cx", content: "purchase-offer")
    else
      utm_params(source: "sendgrid", campaign: "sell")
    end
  end
end
