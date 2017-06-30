require 'net/http'
class Asset < ActiveRecord::Base
  GeminiHttpException = Class.new(StandardError)

  TYPES = ['image'].freeze
  belongs_to :submission

  validates :asset_type, inclusion: { in: TYPES }

  scope :images, -> { where(asset_type: 'image') }

  def update_image_urls!(params = {})
    version = params[:image_url].keys.first
    url = params[:image_url].values.first
    return self unless version && url
    Asset.where(id: id).update_all(['image_urls = jsonb_set(image_urls, ?, ?)', "{#{version}}", "\"#{url}\""])
  end

  def original_image
    return unless gemini_token
    uri = URI.parse("#{Convection.config.gemini_app}/original.json?token=#{gemini_token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}", 'Content-Type' => 'application/json')
    req.basic_auth Convection.config.gemini_account_key, nil
    response = http.request(req)
    raise GeminiHttpException, "#{response.code}: #{response.body}" unless response.code == '302'
    response['location']
  end
end
