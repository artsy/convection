class Submission < ActiveRecord::Base
  STATES = %w(
    draft
    submitted
    approved
    rejected
  ).freeze
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

  def thumbnail
    thumbnail_image = images.select { |image| image.image_urls['thumbnail'].present? }.first
    return thumbnail_image.image_urls['thumbnail'] if thumbnail_image
  end

  # defines methods submitted?, approved?, etc. for each possible submission state
  STATES.each do |method|
    define_method "#{method}?".to_sym do
      state == method
    end
  end

  def ready?
    finished_processing_images_for_email? ||
      receipt_sent_at && (Time.now.utc > receipt_sent_at + Convection.config.processing_grace_seconds)
  end

  def unreviewed?
    draft? || submitted?
  end

  def reviewed_by_user
    admin_user_id = approved_by || rejected_by
    Gravity.client.user(id: admin_user_id)._get if admin_user_id
  rescue Faraday::ResourceNotFound
    nil
  end

  def artist
    Gravity.client.artist(id: artist_id)._get if artist_id
  rescue Faraday::ResourceNotFound
    nil
  end

  def artist_name
    artist.try(:name)
  end

  def user
    Gravity.client.user(id: user_id)._get if user_id
  rescue Faraday::ResourceNotFound
    nil
  end

  def user_name
    user.try(:name)
  end

  def user_detail
    user.try(:user_detail)
  rescue Faraday::ResourceNotFound
    nil
  end
end
