class Submission < ActiveRecord::Base
  STATES = %w(draft submitted qualified).freeze
  DIMENSION_METRICS = %w(in cm).freeze
  CATEGORIES = [
    'Painting',
    'Sculpture',
    'Photography',
    'Print',
    'Drawing, Collage or other Work on Paper',
    'Mixed Media',
    'Performance Art',
    'Installation',
    'Video/Film/Animation',
    'Architecture',
    'Fashion Design and Wearable Art',
    'Jewelry',
    'Design/Decorative Art',
    'Textile Arts',
    'Other'
  ].freeze
  REQUIRED_FIELDS_FOR_SUBMISSION = %w(
    artist_id
    category
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
  validates :state, inclusion: { in: STATES }
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true
  validates :dimensions_metric, inclusion: { in: DIMENSION_METRICS }, allow_nil: true

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

  def finished_processing_images_for_email?
    processed_images.length == images.length
  end

  def processed_images
    images.select { |image| image.image_urls['medium_rectangle'].present? }
  end

  def images
    assets.where(asset_type: 'image')
  end

  def ready?
    finished_processing_images_for_email? || Time.now.utc > receipt_sent_at + Convection.config.processing_grace_seconds
  end
end
