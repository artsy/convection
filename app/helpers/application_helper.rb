# frozen_string_literal: true

module ApplicationHelper
  def price_display(currency, price_cents)
    return if price_cents.blank?

    "#{currency} #{Money.new(price_cents, currency).format(no_cents: true)}"
  end

  def markdown_formatted(text)
    return if text.blank?

    markdown = MarkdownParser.render(text)
    markdown.html_safe
  end

  def humanized_options_for_select(values, **args)
    options_for_select(
      values.map { |value, _| [value.to_s.humanize, value] },
      **args
    )
  end

  def filter_by_assigned_to_options
    AdminUser.assignees.map do |admin|
      [admin.name, admin.gravity_user_id]
    end.unshift(%w[all all], ['none', nil])
  end

  def filter_by_cataloguers_options
    AdminUser.cataloguers.map do |cataloguer|
      [cataloguer.name, cataloguer.gravity_user_id]
    end.unshift(%w[all all], ['none', nil])
  end

  def super_admin_user?(user_id)
    AdminUser.exists?(gravity_user_id: user_id, super_admin: true)
  end
end
