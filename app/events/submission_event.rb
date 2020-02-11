# frozen_string_literal: true

class SubmissionEvent < Events::BaseEvent
  TOPIC = 'consignments'
  ACTIONS = [SUBMITTED = 'submitted', APPROVED = 'approved'].freeze

  def object
    { id: @object.id, display: "#{@object.id} (#{@object.state})" }
  end

  def subject
    {
      id: @object.user.gravity_user_id,
      display: "#{@object.user.gravity_user_id} (#{@object.location_city})"
    }
  end

  def properties
    {
      title: @object.title,
      artist_id: @object.artist_id,
      state: @object.state,
      year: @object.year,
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
      offer_link: Convection.config.auction_offer_form_url
    }
  end

  def large_image_urls
    @object.large_images&.map { |img| img.image_urls['large'] }
  end
end
