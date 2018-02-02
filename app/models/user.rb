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
<<<<<<< HEAD
    gravity_user&.user_detail&._get
=======
    fetched_user = gravity_user
    return unless fetched_user
    fetched_user.try(:user_detail)._get
>>>>>>> search by users wip
  rescue Faraday::ResourceNotFound
    nil
  end
end
