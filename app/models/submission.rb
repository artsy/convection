class Submission < ActiveRecord::Base
  VALID_STATUSES = %w(draft submitted qualified).freeze

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
    %w( artist_id
        dimensions_metric
        height
        location_city
        medium
        title
        user_id
        width
        year ).all? { |attr| self[attr].present? }
  end

  def set_status
    self.status ||= 'draft'
  end

  def as_json(_options = {})
    super(
      include: [:assets]
    )
  end
end
