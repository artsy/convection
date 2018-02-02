class User < ApplicationRecord
  validates :gravity_user_id, presence: true, uniqueness: true

  has_many :submissions, dependent: :nullify

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
end
