class Asset < ActiveRecord::Base
  VALID_TYPES = ['image'].freeze
  belongs_to :submission

  validates :asset_type, inclusion: { in: VALID_TYPES }
end
