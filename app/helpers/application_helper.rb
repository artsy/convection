# frozen_string_literal: true

module ApplicationHelper
  def price_display(currency, price_cents)
    return if price_cents.blank?

    "#{currency} #{Money.new(price_cents, currency).format(no_cents: true)}"
  end

  def markdown_formatted(text)
    return if text.blank?

    markdown = MarkdownParser.render(text)
    markdown.html_safe # rubocop:disable Rails/OutputSafety
  end
end
