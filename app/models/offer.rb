class Offer < ApplicationRecord
  include ReferenceId
  include PgSearch
  include Currency

  pg_search_scope :search,
    against: [:id, :reference_id],
    associated_against: {
      partner: [:name]
    },
    using: {
      tsearch: { prefix: true }
    }

  OFFER_TYPES = [
    AUCTION_CONSIGNMENT = 'auction consignment'.freeze,
    NET_PRICE = 'net price'.freeze,
    RETAIL = 'retail'.freeze,
    PURCHASE = 'purchase'.freeze
  ].freeze

  # FIXME: deprecate 'accepted' state
  STATES = %w[
    draft
    sent
    accepted
    rejected
    lapsed
    review
    locked
    consigned
  ].freeze

  REJECTION_REASONS = [
    'Low estimate',
    'High commission',
    'High shipping/marketing costs',
    'Took competing offer',
    'Lost interest',
    'Other'
  ].freeze

  belongs_to :partner_submission
  belongs_to :submission, counter_cache: true
  has_one :partner, through: :partner_submission

  validates :state, inclusion: { in: STATES }
  validates :offer_type, inclusion: { in: OFFER_TYPES }, allow_nil: true
  validates :rejection_reason, inclusion: { in: REJECTION_REASONS }, allow_nil: true

  before_validation :set_state, on: :create
  before_create :set_submission

  scope :sent, -> { where(state: 'sent') }

  def set_state
    self.state ||= 'draft'
  end

  # defines methods sent?, accepted?, etc. for each possible offer state
  STATES.each do |method|
    define_method "#{method}?".to_sym do
      state == method
    end
  end

  def reviewed?
    !draft? && !sent? && !review?
  end

  def rejected_by_user
    Gravity.client.user(id: rejected_by)._get if rejected_by
  rescue Faraday::ResourceNotFound
    nil
  end

  def set_submission
    self.submission ||= partner_submission&.submission
  end

  def best_price_display
    amount = price_cents || high_estimate_cents || low_estimate_cents
    return unless amount
    Money.new(amount, currency).format
  end
end
