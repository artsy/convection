class User < ApplicationRecord
  include PgSearch

  validates :gravity_user_id, presence: true, uniqueness: true

  has_many :submissions, dependent: :nullify

  pg_search_scope :search,
    against: :email,
    using: {
      tsearch: { prefix: true }
    }

  def gravity_user
    Gravity.client.user(id: gravity_user_id)._get
  rescue Faraday::ResourceNotFound
    nil
  end

  def name
    gravity_user.try(:name)
  end

  def user_detail
    gravity_user&.user_detail&._get
  rescue Faraday::ResourceNotFound
    nil
  end

  def consignor_number
    created_at.to_i % 100_000 + id
  end
end
