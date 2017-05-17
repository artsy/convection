class Submission < ActiveRecord::Base
  VALID_STATES = %w(draft submitted qualified).freeze
  REQUIRED_FIELDS_FOR_SUBMISSION = %w(
    artist_id
    dimensions_metric
    height
    location_city
    medium
    title
    user_id
    width
    year
  ).freeze

  has_many :assets, dependent: :destroy
  validates :state, inclusion: { in: VALID_STATES }

  before_validation :set_state, on: :create

  def formatted_location
    [location_city, location_state, location_country].select(&:present?).join(', ')
  end

  def formatted_dimensions
    values = [height, width, depth].select(&:present?)
    return if values.empty?
    "#{values.join(' x ')} #{dimensions_metric.try(:downcase)}"
  end

  def can_submit?
    REQUIRED_FIELDS_FOR_SUBMISSION.all? { |attr| self[attr].present? }
  end

  def set_state
    self.state ||= 'draft'
  end
end
