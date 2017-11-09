class Partner < ApplicationRecord
  include PgSearch

  default_scope { order('name ASC') }
  pg_search_scope :search_by_name,
    against: :name,
    using: {
      tsearch: { prefix: true }
    }

  has_many :partner_submissions
end
