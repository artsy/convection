# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch::Model

  has_one :submission, dependent: :nullify
  has_many :notes, dependent: :nullify

  pg_search_scope :search, against: :email, using: { tsearch: { prefix: true } }

  def gravity_user
    if defined?(@gravity_user)
      @gravity_user
    elsif gravity_user_id
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

  def user_submissions
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
end
