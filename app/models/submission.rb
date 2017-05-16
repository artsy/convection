class Submission < ActiveRecord::Base
  VALID_STATUSES = ['draft', 'submitted', 'qualified'].freeze

  has_many :assets, dependent: :destroy
  validates :status, inclusion: { in: VALID_STATUSES }

  after_initialize :set_status

  def formatted_location
    [location_city, location_state, location_country].select(&:present?).join(', ')
  end

  def formatted_dimensions
    values = [height, width, depth].select(&:present?)
    return if values.empty?
    "#{values.join(' x ')} #{dimensions_metric.try(:downcase)}"
  end

  def can_submit?
    user_id.present? && artist_id.present? && title.present? && medium.present? &&
    year.present? && height.present? && width.present? && dimensions_metric.present? && location_city.present?
  end

  def set_status
    self.status ||= 'draft'
  end
end
