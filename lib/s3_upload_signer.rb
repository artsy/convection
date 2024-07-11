class S3UploadSigner
  require "base64"
  require "openssl"
  require "digest/sha1"

  DEFAULTS = {
    acl: "private",
    max_file_size: 100.megabyte
  }.with_indifferent_access

  def initialize(options = {})
    @options = initialize_options(options)
  end

  def as_json
    {
      policy_encoded: policy_encoded,
      policy_document: policy_document,
      signature: signature,
      credentials: Convection.config[:aws_access_key_id]
    }
  end

  private

  def initialize_options(options = {})
    DEFAULTS.merge(options)
  end

  def policy_encoded
    Base64.encode64(policy_document.to_json).delete("\n")
  end

  def token
    SecureRandom.urlsafe_base64
  end

  def signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new("sha1"),
        Convection.config[:aws_secret_access_key],
        policy_encoded
      )
    ).delete("\n")
  end

  def policy_document
    @policy_document ||= {
      "expiration" => 10.hours.from_now.utc.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
      "conditions" => [
        {"bucket" => Convection.config[:aws_upload_bucket]},
        ["starts-with", "$key", token],
        {"acl" => @options[:acl]},
        {"success_action_status" => "201"},
        ["content-length-range", 0, @options[:max_file_size]],
        ["starts-with", "$Content-Type", ""]
      ]
    }
  end
end
