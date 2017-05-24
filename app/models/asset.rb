class Asset < ActiveRecord::Base
  TYPES = ['image'].freeze
  belongs_to :submission

  validates :asset_type, inclusion: { in: TYPES }

  scope :images, -> { where(asset_type: 'image') }

  def update_image_urls!(params = {})
    version = params[:image_url].keys.first
    url = params[:image_url].values.first
    return self unless version && url
    Asset.where(id: id).update_all(['image_urls = jsonb_set(image_urls, ?, ?)', "{#{version}}", "\"#{url}\""]) # rubocop:disable Rails/SkipsModelValidations
  end
end
