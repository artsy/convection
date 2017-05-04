class Asset < ActiveRecord::Base
  VALID_TYPES = ['image'].freeze
  belongs_to :submission

  validates :asset_type, inclusion: { in: VALID_TYPES }

  def update_image_urls!(params = {})
    version = params[:image_url].keys.first
    url = params[:image_url].values.first
    return self unless version && url
    image_urls[version] = url
    save!
  end
end
