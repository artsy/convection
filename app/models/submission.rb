class Submission < ApplicationRecord
  include Currency
  include Dollarize
  include PgSearch::Model

  alias_attribute :deleted?, :deleted_at

  scope :not_deleted, -> { where(deleted_at: nil) }

  pg_search_scope :search,
    against: [:id, :title],
    using: {
      tsearch: { prefix: true },
      trigram: {}
    }

  STATES = [
    DRAFT = 'draft'.freeze,
    SUBMITTED = 'submitted'.freeze,
    APPROVED = 'approved'.freeze,
    REJECTED = 'rejected'.freeze
  ].freeze

  DIMENSION_METRICS = %w[in cm].freeze

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

  REQUIRED_FIELDS_FOR_SUBMISSION = %w[
    artist_id
    category
    title
    user_id
    year
  ].freeze

  delegate :images, to: :assets

  has_many :assets, dependent: :destroy
  has_many :partner_submissions, dependent: :destroy
  has_many :offers, dependent: :destroy
  belongs_to :user
  belongs_to :primary_image, class_name: 'Asset' # rubocop:disable Rails/InverseOf
  belongs_to :consigned_partner_submission, class_name: 'PartnerSubmission' # rubocop:disable Rails/InverseOf

  validates :state, inclusion: { in: STATES }
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true
  validates :dimensions_metric, inclusion: { in: DIMENSION_METRICS }, allow_nil: true
  validate :validate_primary_image

  before_validation :set_state, on: :create
  before_save :set_artist_standing_scores

  scope :completed, -> { where.not(state: 'draft') }
  scope :draft, -> { where(state: 'draft') }
  scope :submitted, -> { where(state: 'submitted') }

  dollarize :minimum_price_cents

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

  def large_images
    images.select { |image| image.image_urls['large'].present? }
  end

  def thumbnail
    possible_thumbnails = images.to_a.unshift(primary_image).compact
    thumbnails = possible_thumbnails.map { |image| image.image_urls['thumbnail'] }.compact
    thumbnails.first
  end

  # defines methods submitted?, approved?, etc. for each possible submission state
  STATES.each do |method|
    define_method "#{method}?".to_sym do
      state == method
    end
  end

  def reviewed?
    approved? || rejected?
  end

  def ready?
    finished_processing_images_for_email? ||
      receipt_sent_at && (Time.now.utc > receipt_sent_at + Convection.config.processing_grace_seconds)
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

  def set_artist_standing_scores
    recent_draft = changes['state']&.include?(DRAFT) || state == DRAFT
    worth_calculating = %i[category artist_id].any? { |attr| changes[attr].present? }
    return unless recent_draft && worth_calculating
    artist_standing_score = ArtistStandingScore.find_by(artist_id: artist_id)
    self.artist_score = calculate_demand_score(artist_standing_score&.artist_score)
    self.auction_score = calculate_demand_score(artist_standing_score&.auction_score)
  end

  # TODO: Move into own service
  def calculate_demand_score(base_score)
    return 0 unless base_score&.positive?
    category_modifiers = {
      'Painting' => 1,
      'Print' => 0.75
    }

    base_score * category_modifiers.fetch(category, 0.5)
  end

  def artist_name
    artist.try(:name)
  end

  def validate_primary_image
    return if primary_image.blank?
    errors.add(:primary_image, 'Primary image must have asset_type=image') unless primary_image.asset_type == 'image'
  end
end
