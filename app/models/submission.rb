class Submission < ActiveRecord::Base
  has_many :assets, dependent: :destroy

  def formatted_location
    [location_city, location_state, location_country].reject(&:blank?).join(', ')
  end

  def formatted_dimensions
    values = [height, width, depth].reject(&:blank?)
    return unless values.any?
    "#{values.join(' x ')} #{dimensions_metric.try(:downcase)}"
  end
end
