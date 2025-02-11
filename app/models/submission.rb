# frozen_string_literal: true

class Submission < ApplicationRecord
  include Currency
  include Dollarize
  include PgSearch::Model
  include ReloadUuid

  alias_attribute :deleted?, :deleted_at

  scope :not_deleted, -> { where(deleted_at: nil) }

  pg_search_scope :search,
    against: %i[id title],
    using: {
      tsearch: {
        prefix: true
      },
      trigram: {
        only: %i[id],
        threshold: 0.9
      }
    }

  STATES = [
    DRAFT = "draft",
    SUBMITTED = "submitted",
    APPROVED = "approved",
    RESUBMITTED = "resubmitted",
    PUBLISHED = "published",
    REJECTED = "rejected",
    HOLD = "hold",
    CLOSED = "closed"
  ].freeze

  SOURCES = [
    WEB_INBOUND = "web_inbound",
    APP_INBOUND = "app_inbound",
    ADMIN = "admin",
    PARTNER = "partner",
    MY_COLLECTION = "my_collection"
  ].freeze

  enum attribution_class: {
    unique: 0,
    limited_edition: 1,
    open_edition: 2,
    unknown_edition: 3
  }

  REJECTION_REASONS = [
    "BSV",
    "Fake",
    "Artist Submission",
    "NSV",
    "Other"
  ].freeze

  DIMENSION_METRICS = %w[in cm].freeze

  CATEGORIES = [
    "Painting",
    "Sculpture",
    "Photography",
    "Print",
    "Drawing, Collage or other Work on Paper",
    "Mixed Media",
    "Performance Art",
    "Installation",
    "Video/Film/Animation",
    "Architecture",
    "Fashion Design and Wearable Art",
    "Jewelry",
    "Design/Decorative Art",
    "Textile Arts",
    "Other"
  ].freeze

  REQUIRED_FIELDS_FOR_SUBMISSION = %w[artist_id title category].freeze

  delegate :images, to: :assets

  has_many :assets, dependent: :destroy
  has_many :partner_submissions, dependent: :destroy
  has_many :offers, dependent: :destroy
  has_many :notes, dependent: :nullify
  belongs_to :user
  belongs_to :admin, class_name: "AdminUser"
  belongs_to :primary_image, class_name: "Asset"
  belongs_to :consigned_partner_submission, class_name: "PartnerSubmission"

  validates :state, inclusion: {in: STATES}
  validates :source, inclusion: {in: SOURCES}, allow_nil: true
  validates :category, inclusion: {in: CATEGORIES}, allow_nil: true
  validates :dimensions_metric,
    inclusion: {
      in: DIMENSION_METRICS
    },
    allow_nil: true
  validate :validate_primary_image

  before_validation :set_state, on: :create
  before_create :calculate_demand_scores
  before_update :calculate_demand_scores, if: :worth_recalculating?

  scope :completed, -> { where.not(state: "draft") }
  scope :draft, -> { where(state: "draft") }
  scope :submitted, -> { where(state: "submitted") }
  scope :resubmitted, -> { where(state: "resubmitted") }
  scope :available,
    -> { where(state: PUBLISHED, consigned_partner_submission_id: nil) }

  dollarize :minimum_price_cents

  def sale_state
    consigned_partner_submission&.state
  end

  def sorted_images
    images.sort_by.with_index { |a, i| (a == primary_image) ? -1 : i }
  end

  def as_json(options = {})
    if options[:properties] == :short
      return(
        {
          id: id,
          uuid: uuid,
          state: state,
          rejection_reason: rejection_reason,
          sale_state: sale_state,
          # Added to save REST API behavior. Should be removed after migration MP to GraphQL query
          consignment_state: sale_state,
          consigned_partner_submission_id: consigned_partner_submission_id
        }.as_json
      )
    end

    super(methods: :sale_state).merge(
      {
        # Added to save REST API behavior. Should be removed after migration MP to GraphQL query
        "consignment_state" => sale_state
      }
    )
  end

  def can_submit?
    REQUIRED_FIELDS_FOR_SUBMISSION.all? { |attr| self[attr].present? }
  end

  def set_state
    self.state ||= "draft"
  end

  def finished_processing_images_for_email?
    processed_images.length == images.length
  end

  def processed_images
    images.select { |image| image.image_urls["square"].present? }
  end

  def large_images
    images.select { |image| image.image_urls["large"].present? }
  end

  def thumbnail
    primary_image&.image_urls&.fetch("thumbnail", nil)
  end

  # defines methods submitted?, approved?, etc. for each possible submission state
  STATES.each do |method|
    define_method :"#{method}?" do
      state == method
    end
  end

  def reviewed?
    approved? || published? || rejected? || closed?
  end

  def ready?
    finished_processing_images_for_email? ||
      receipt_sent_at &&
        (
          Time.now.utc >
            receipt_sent_at + Convection.config.processing_grace_seconds
        )
  end

  def reviewed_by_user
    admin_user_id = approved_by || rejected_by
    Gravity.client.user(id: admin_user_id)._get if admin_user_id
  rescue Faraday::ResourceNotFound
    nil
  end

  def calculate_demand_scores
    scores = DemandCalculator.score(artist_id, category)
    self.artist_score = scores[:artist_score]
    self.auction_score = scores[:auction_score]
  end

  def worth_recalculating?
    in_draft_state = state == DRAFT
    relevant_fields = %w[artist_id category]
    has_relevant_change = (changes.keys & relevant_fields).any?
    in_draft_state && has_relevant_change
  end

  def validate_primary_image
    return if primary_image.blank?

    return if primary_image.asset_type == "image"

    errors.add(:primary_image, "Primary image must have asset_type=image")
  end

  def exchange_assigned_to_real_user!
    admin_gravity_id = AdminUser.find_by(name: assigned_to)&.gravity_user_id

    return if assigned_to == admin_gravity_id

    update(assigned_to: admin_gravity_id)
  end

  def email
    user_email || user&.email
  end

  def name
    user_name || user&.name
  end

  def phone
    user_phone || user&.phone
  end

  def count_submissions_of_user
    return 1 if user.nil? && user_email.blank?
    return Submission.where(user_email: user_email).count if user.nil?

    user.submissions.count
  end

  def unique_code_for_digest
    created_at.to_i % 100_000 + (user_id || id) +
      (count_submissions_of_user || 0)
  end

  def to_artwork_params
    {
      title: title,
      artists: [artist_id.presence].compact,
      category: category,
      medium: medium,
      date: year,
      height: height,
      width: width,
      depth: depth,
      metric: dimensions_metric,
      signed_by_artist: signature,
      certificate_of_authenticity: authenticity_certificate,
      provenance: provenance,
      additional_information: additional_info,
      attribution_class: attribution_class&.humanize&.downcase,
      publisher: publisher,
      literature: literature,
      exhibition_history: exhibition,
      condition_description: condition_report,
      signature: signature_detail,
      coa_by_authenticating_body: coa_by_authenticating_body,
      coa_by_gallery: coa_by_gallery
    }
  end

  def to_edition_set_params
    {
      edition_size: edition_size,
      available_editions: [edition_number.presence].compact,
      artist_proofs: artist_proofs,
      height: height,
      width: width,
      depth: depth,
      metric: dimensions_metric
    }
  end

  def likely_edition?
    edition? || edition_size.present? || edition_number.present?
  end

  def salesforce_artwork
    @salesforce_artwork ||= SalesforceService.salesforce_artwork_for_submission(self)
  end
end
