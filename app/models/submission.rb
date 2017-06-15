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
    location_city
    title
    user_id
    year
  ).freeze

  delegate :images, to: :assets

  has_many :assets, dependent: :destroy
  validates :state, inclusion: { in: STATES }
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true
  validates :dimensions_metric, inclusion: { in: DIMENSION_METRICS }, allow_nil: true

  before_validation :set_state, on: :create

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
    images.select { |image| image.image_urls['square'].present? }
  end

  def ready?
    finished_processing_images_for_email? ||
      receipt_sent_at && (Time.now.utc > receipt_sent_at + Convection.config.processing_grace_seconds)
  end

  def submitted?
    state == 'submitted'
  end
end
