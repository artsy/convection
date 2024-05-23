class MyCollectionArtworkUpdatedService
  def initialize(payload)
    @user_data = payload[:subject]
    @artwork_data = payload[:object]
    @changes = payload[:properties][:changes]
  end

  def notify_admin!
    Rails.logger.info("I will notify the admin about the changes to the MyC artwork.")
  end
end
