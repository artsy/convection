class Offer < ApplicationRecord
  OFFER_TYPES = [
    'auction consignment',
    'consignment period',
    'purchase'
  ].freeze

  STATES = %w(
    draft
    sent
  ).freeze

  CURRENCIES = %w(
    USD
    EUR
    GBP
  ).freeze

  belongs_to :partner_submission
  belongs_to :submission

  validates :state, inclusion: { in: STATES }
  validates :offer_type, inclusion: { in: OFFER_TYPES }, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }, allow_nil: true

  before_validation :set_state, on: :create
  before_create :create_reference_id
  before_create :set_submission

  def set_state
    self.state ||= 'draft'
  end

  def create_reference_id
    loop do
      self.reference_id = SecureRandom.hex(5)
      break unless self.class.exists?(reference_id: reference_id)
    end
  end

  def set_submission
    self.submission ||= partner_submission&.submission
  end
end
