module UrlHelper
  def upload_photo_url(submission_id, utm_params = {})
    utm_url("#{Convection.config.artsy_url}/consign/submission/#{submission_id}/upload", utm_params)
  end

  def artsy_formatted_url(path, utm_params)
    utm_params ||= {}
    utm_url("#{Convection.config.artsy_url}/#{path}", utm_params)
  end

  private

  def utm_url(url, utm_params)
    "#{url}?#{utm_params.to_query}"
  end
end
