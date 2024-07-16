# frozen_string_literal: true

class SubmissionEvent < Events::BaseEvent
  TOPIC = "consignments"

  ACTIONS = [
    APPROVED = "approved",
    PUBLISHED = "published",
    SUBMITTED = "submitted"
  ].freeze

  def object
    {id: @object.id, display: "#{@object.id} (#{@object.state})"}
  end

  def subject
    {
      id: @object.user&.gravity_user_id || @object.user_id,
      display:
        "#{@object.user&.gravity_user_id || @object.user_id} (#{@object.location_city})"
    }
  end

  def properties
    {
      title: @object.title,
      artist_id: @object.artist_id,
      state: @object.state,
      year: @object.year,
      location_address: @object.location_address,
      location_address2: @object.location_address2,
      location_city: @object.location_city,
      location_state: @object.location_state,
      location_country: @object.location_country,
      height: @object.height,
      width: @object.width,
      depth: @object.depth,
      dimensions_metric: @object.dimensions_metric,
      category: @object.category,
      medium: @object.medium,
      minimum_price: @object.minimum_price_display,
      currency: @object.currency,
      provenance: @object.provenance,
      signature: @object.signature,
      authenticity_certificate: @object.authenticity_certificate,
      thumbnail: @object.thumbnail,
      image_urls: large_image_urls,
      offer_link: Convection.config.auction_offer_form_url,
      utm_source: @object.utm_source,
      utm_medium: @object.utm_medium,
      utm_term: @object.utm_term
    }
  end

  def large_image_urls
    @object.large_images&.map { |img| img.image_urls["large"] }
  end
end
