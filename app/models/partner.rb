class Partner < ApplicationRecord
  include PgSearch::Model

  default_scope { order('name ASC') }
  pg_search_scope :search_by_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true }
                  }

  has_many :partner_submissions, dependent: :destroy
  has_many :offers, through: :partner_submissions

  validates :gravity_partner_id, presence: true, uniqueness: true
end
