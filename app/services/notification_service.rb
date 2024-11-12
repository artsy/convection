# frozen_string_literal: true

class NotificationService
  class << self
    def post_submission_event(submission_id, action)
      submission = Submission.find(submission_id) # post notification
      subject_id = submission.user&.gravity_user_id || submission.user_id
      Artsy::EventPublisher.publish(
        "consignments",
        "submission.#{action}",
        verb: action,
        subject: {
          id: subject_id,
          display: "#{subject_id} (#{submission.location_city})"
        },
        object: {id: submission.id.to_s, display: "#{submission.id} (#{submission.state})"},
        properties: {
          title: submission.title,
          artist_id: submission.artist_id,
          state: submission.state,
          year: submission.year,
          location_address: submission.location_address,
          location_address2: submission.location_address2,
          location_city: submission.location_city,
          location_state: submission.location_state,
          location_country: submission.location_country,
          height: submission.height,
          width: submission.width,
          depth: submission.depth,
          dimensions_metric: submission.dimensions_metric,
          category: submission.category,
          medium: submission.medium,
          minimum_price: submission.minimum_price_display,
          currency: submission.currency,
          provenance: submission.provenance,
          signature: submission.signature,
          authenticity_certificate: submission.authenticity_certificate,
          thumbnail: submission.thumbnail,
          image_urls: submission.large_images&.map { |img| img.image_urls["large"] },
          offer_link: Convection.config.auction_offer_form_url,
          utm_source: submission.utm_source,
          utm_medium: submission.utm_medium,
          utm_term: submission.utm_term
        }
      )
    end
  end
end
