class PartnerSubmission < ApplicationRecord
  belongs_to :partner
  belongs_to :submission
end
