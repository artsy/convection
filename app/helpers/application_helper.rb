# frozen_string_literal: true

module ApplicationHelper
  def price_display(currency, price_cents)
    return if price_cents.blank?

    "#{currency} #{Money.new(price_cents, currency).format(no_cents: true)}"
  end
end
