class AssetDownloader
  attr_accessor :asset

  def initialize(asset)
    @asset = asset
  end

  def data
    return unless asset.asset_type == "additional_file"

    aws_client = Aws::S3::Client.new(
      region: "us-east-1",
      access_key_id: Convection.config[:aws_access_key_id],
      secret_access_key: Convection.config[:aws_secret_access_key]
    )
    object = aws_client.get_object(bucket: asset.s3_bucket, key: asset.s3_path)
    object.body.read
  end
end
