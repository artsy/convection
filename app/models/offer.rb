# frozen_string_literal: true

class Offer < ApplicationRecord
  include ReferenceId
  include PgSearch::Model
  include Currency
  include Dollarize
  include Percentize

  pg_search_scope :search,
                  against: %i[id reference_id],
                  associated_against: { partner: %i[name] },
                  using: { tsearch: { prefix: true } }

  OFFER_TYPES = [
    AUCTION_CONSIGNMENT = 'auction consignment',
    NET_PRICE = 'net price',
    RETAIL = 'retail',
    PURCHASE = 'purchase'
  ].freeze

  STATES = [
    DRAFT = 'draft',
    SENT = 'sent',
    ACCEPTED = 'accepted',
    REJECTED = 'rejected',
    LAPSED = 'lapsed',
    REVIEW = 'review'
  ].freeze

  REJECTION_REASONS = [
    'Low estimate',
    'High commission',
    'High shipping/marketing costs',
    'Took competing offer',
    'Lost interest',
    'Inconvenient partner location',
    'Other'
  ].freeze

  belongs_to :partner_submission
  belongs_to :submission, counter_cache: true
  has_one :partner, through: :partner_submission
  has_many :offer_responses, dependent: :destroy

  validates :state, inclusion: { in: STATES }
  validates :offer_type, inclusion: { in: OFFER_TYPES }, allow_nil: true
  validates :rejection_reason,
            inclusion: { in: REJECTION_REASONS }, allow_nil: true

  before_validation :set_state, on: :create
  before_create :set_submission

  scope :sent, -> { where(state: 'sent') }

  dollarize :price_cents, :low_estimate_cents, :high_estimate_cents,
            :starting_bid_cents

  percentize :commission_percent

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

  def locked?
    submission.consigned_partner_submission_id.present? &&
      submission.consigned_partner_submission.accepted_offer_id != id
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
