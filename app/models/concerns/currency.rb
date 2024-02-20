# frozen_string_literal: true

module Currency
  extend ActiveSupport::Concern

  SUPPORTED = %w[USD EUR GBP CAD HKD].freeze

  included do
    validates :currency, inclusion: {in: SUPPORTED}, allow_nil: true

    before_validation :set_currency
  end

  def set_currency
    self.currency ||= "USD"
  end
end
