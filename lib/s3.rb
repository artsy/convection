# frozen_string_literal: true

class S3
  DEFAULT_EXPIRES_IN = 180 # seconds

  attr_accessor :aws_client, :s3

  def initialize
    @aws_client = Aws::S3::Client.new(region: Convection.config[:aws_region], access_key_id: Convection.config[:aws_access_key_id], secret_access_key: Convection.config[:aws_secret_access_key])
    @s3 = Aws::S3::Resource.new(client: @aws_client)
  end

  def object(bucket:, object_path:)
    bucket = s3.bucket(bucket)
    bucket.object(object_path)
  end

  def presigned_url(bucket:, object_path:, expires_in: DEFAULT_EXPIRES_IN)
    bucket = s3.bucket(bucket)
    obj = bucket.object(object_path)
    obj.presigned_url(:get, expires_in: 60)
  end
end
