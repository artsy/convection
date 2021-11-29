# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch::Model

  validates :gravity_user_id, presence: true, unless: :contact_information?

  has_one :submission, dependent: :nullify
  has_many :notes, dependent: :nullify

  pg_search_scope :search, against: :email, using: { tsearch: { prefix: true } }

  def gravity_user
    return @gravity_user if defined?(@gravity_user)
    return nil unless gravity_user_id

    @gravity_user =
      gravity_user_id &&
        (
          begin
            Gravity.client.user(id: gravity_user_id)._get
          rescue Faraday::ResourceNotFound
            nil
          end
        )
  end

  def name
    self[:name] || gravity_user.try(:name)
  end

  def email
    self[:email] || user_detail&.email
  end

  def phone
    self[:phone] || user_detail&.phone
  end

  def user_detail
    gravity_user&.user_detail&._get
  rescue Faraday::ResourceNotFound
    nil
  end

  def submissions
    users =
      if gravity_user_id
        User.where(gravity_user_id: gravity_user_id)
      else
        User.where(name: name, email: email, phone: phone)
      end

    users.map(&:submission).compact
  end

  def unique_code_for_digest
    created_at.to_i % 100_000 + id + (submission&.id || 0)
  end

  def self.anonymous
    User.find_or_create_by(gravity_user_id: 'anonymous')
  end

  def contact_information?
    self[:name].present? && self[:email].present? && self[:phone].present?
  end
end
