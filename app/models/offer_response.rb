# frozen_string_literal: true

class OfferResponse < ApplicationRecord
  INTENDED_STATES = [Offer::ACCEPTED, Offer::REJECTED, Offer::REVIEW].freeze

  belongs_to :offer

  validates :intended_state, inclusion: { in: INTENDED_STATES }
  validates :rejection_reason,
            inclusion: { in: Offer::REJECTION_REASONS }, allow_nil: true
end
