class Submission < ActiveRecord::Base
  has_many :assets, dependent: :destroy

  def formatted_location
    [location_city, location_state, location_country].select(&:present?).join(', ')
  end

  def formatted_dimensions
    values = [height, width, depth].select(&:present?)
    return if values.empty?
    "#{values.join(' x ')} #{dimensions_metric.try(:downcase)}"
  end
end
