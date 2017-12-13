class Offer < ApplicationRecord
  OFFER_TYPES = [
    'auction consignment',
    'consignment period',
    'purchase'
  ].freeze

  STATES = %w(
    sent
  ).freeze

  belongs_to :partner_submission

  validates :state, inclusion: { in: STATES }
  validates :offer_type, inclusion: { in: OFFER_TYPES }, allow_nil: true

  before_validation :set_state, on: :create
  before_create :create_reference_id

  def set_state
    self.state ||= 'sent'
  end

  def create_reference_id
    loop do
      self.reference_id = SecureRandom.hex(5)
      break unless self.class.exists?(reference_id: reference_id)
    end
  end
end
