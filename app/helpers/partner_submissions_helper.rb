module PartnerSubmissionsHelper
  def new_time_field_value(current_value)
    if current_value.present?
      nil
    else
      Time.now.utc
    end
  end
end
