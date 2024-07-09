# frozen_string_literal: true

require "net/http"
class Asset < ApplicationRecord
  GeminiHttpException = Class.new(StandardError)

  TYPES = %w[image additional_file].freeze

  belongs_to :submission
  has_one :user, through: :submission

  validates :asset_type, inclusion: {in: TYPES}

  before_create :set_filesize

  scope :images, -> { where(asset_type: "image") }

  def update_image_urls!(params = {})
    version = params[:image_url].keys.first
    url = params[:image_url].values.first
    return self unless version && url

    Asset
      .where(id: id)
      .update_all(
        [
          "image_urls = jsonb_set(image_urls, ?, ?)",
          "{#{version}}",
          "\"#{url}\""
        ]
      )
  end

  def original_image
    return unless gemini_token

    uri =
      URI.parse(
        "#{Convection.config.gemini_app}/original.json?token=#{gemini_token}"
      )
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req =
      Net::HTTP::Get.new(
        "#{uri.path}?#{uri.query}",
        "Content-Type" => "application/json"
      )
    req.basic_auth Convection.config.gemini_account_key, nil
    response = http.request(req)
    unless response.code == "302"
      raise GeminiHttpException, "#{response.code}: #{response.body}"
    end

    response["location"]
  end

  def document_path
    return unless asset_type == "additional_file"

    S3.new.presigned_url(bucket: s3_bucket, object_path: s3_path)
  end

  private

  def set_filesize
    return unless asset_type == "additional_file"
    return if !s3_bucket || !s3_path

    size = S3.new.object(bucket: s3_bucket, object_path: s3_path).size
    self.size = size
  end
end
