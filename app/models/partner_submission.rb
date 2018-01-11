class PartnerSubmission < ApplicationRecord
  include ReferenceId

  belongs_to :partner
  belongs_to :submission
  has_many :offers
  belongs_to :accepted_offer, class_name: 'Offer'

  STATES = [
    'open',
    'unconfirmed',
    'signed',
    'sold',
    'bought in',
    'closed'
  ].freeze

  scope :group_by_day, -> { group("date_trunc('day', notified_at) ") }
  scope :consigned, -> { where.not(accepted_offer_id: nil) }

  validates :state, inclusion: { in: STATES }, allow_nil: true

  before_validation :set_state, on: :create

  def set_state
    self.state ||= 'open'
  end
end
