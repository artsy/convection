# frozen_string_literal: true

module PartnerSubmissionsHelper
  def new_time_field_value(current_value)
    current_value.present? ? nil : Time.now.utc
  end
end
