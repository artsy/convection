class Asset < ActiveRecord::Base
  VALID_ASSETS = ['image'].freeze
  belongs_to :submission, dependent: :destroy

  validates :asset_type, inclusion: { in: VALID_ASSETS }
end
