# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch::Model

  before_save :set_gravity_user_id

  has_many :submissions, dependent: :nullify
  has_many :notes, dependent: :nullify

  pg_search_scope :search, against: :email, using: {tsearch: {prefix: true}}

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
    gravity_user.try(:name)
  end

  def email
    self[:email] || user_detail&.email
  end

  def phone
    user_detail&.phone
  end

  def user_detail
    gravity_user&.user_detail&._get
  rescue Faraday::ResourceNotFound
    nil
  end

  def unique_code_for_digest
    created_at.to_i % 100_000 + id + (submissions.first&.id || 0)
  end

  def self.anonymous
    User.find_or_create_by(gravity_user_id: "anonymous")
  end

  def set_gravity_user_id
    self.gravity_user_id = nil if gravity_user_id.blank?
  end
end
