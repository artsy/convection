# frozen_string_literal: true

module UrlHelper
  def upload_photo_url(submission_id, utm_params = {})
    utm_url(
      "#{Convection.config.artsy_url}/consign/submission/#{
        submission_id
      }/upload",
      utm_params
    )
  end

  def artsy_formatted_url(path, utm_params)
    utm_params ||= {}
    utm_url("#{Convection.config.artsy_url}/#{path}", utm_params)
  end

  def offer_form_url(submission_id: "")
    Convection.config.auction_offer_form_url.gsub(
      "SUBMISSION_NUMBER",
      submission_id.to_s
    )
  end

  def offer_response_form_url(submission_id: "", partner_name: "")
    url =
      Convection.config.offer_response_form_url.gsub(
        "SUBMISSION_NUMBER",
        submission_id.to_s
      )
    url.gsub("PARTNER_NAME", partner_name)
  end

  def user_management_url(gravity_user_id)
    "#{Convection.config.forque_url}/users/#{gravity_user_id}"
  end

  def artwork_url(artwork_id)
    "#{Convection.config.artsy_url}/artwork/#{artwork_id}"
  end

  private

  def utm_url(url, utm_params)
    "#{url}?#{utm_params.to_query}"
  end
end
