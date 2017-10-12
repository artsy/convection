class PartnerSubmission < ApplicationRecord
  belongs_to :partner
  belongs_to :submission

  scope :group_by_day, -> { group("date_trunc('day', created_at) ") }
end
