# frozen_string_literal: true

class PartnerSubmission < ApplicationRecord
  include ReferenceId
  include PgSearch::Model
  include Currency
  include Dollarize
  include Percentize

  pg_search_scope :search,
                  against: %i[id reference_id],
                  associated_against: { partner: %i[name] },
                  using: {
                    tsearch: { prefix: true, negation: true },
                    trigram: {
                      only: %i[id reference_id],
                      threshold: 0.9
                    }
                  }

  belongs_to :partner
  belongs_to :submission
  has_many :offers, dependent: :destroy
  belongs_to :accepted_offer, class_name: 'Offer'

  STATES = ['open', 'sold', 'bought in', 'canceled', 'withdrawn - pre-launch', 'withdrawn - post-launch'].freeze

  scope :group_by_day, -> { group("date_trunc('day', notified_at) ") }
  scope :consigned, -> { where.not(accepted_offer_id: nil) }

  validates :state, inclusion: { in: STATES }, allow_nil: true

  before_validation :set_state, on: :create

  dollarize :sale_price_cents

  percentize :partner_commission_percent, :artsy_commission_percent

  def set_state
    self.state ||= 'open'
  end
end
