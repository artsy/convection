class Offer < ApplicationRecord
  include ReferenceId

  OFFER_TYPES = [
    'auction consignment',
    'consignment period',
    'purchase'
  ].freeze

  STATES = %w[
    draft
    sent
    accepted
    rejected
    lapsed
  ].freeze

  CURRENCIES = %w[
    USD
    EUR
    GBP
    CAD
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
  belongs_to :submission

  validates :state, inclusion: { in: STATES }
  validates :offer_type, inclusion: { in: OFFER_TYPES }, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }, allow_nil: true
  validates :rejection_reason, inclusion: { in: REJECTION_REASONS }, allow_nil: true

  before_validation :set_state, on: :create
  before_validation :set_currency
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

  def recorded_by_user
    admin_user_id = accepted_by || rejected_by
    Gravity.client.user(id: admin_user_id)._get if admin_user_id
  rescue Faraday::ResourceNotFound
    nil
  end

  def set_submission
    self.submission ||= partner_submission&.submission
  end

  def set_currency
    self.currency ||= 'USD'
  end
end
