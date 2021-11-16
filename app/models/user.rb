# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch::Model

  has_many :submissions, dependent: :nullify
  has_many :notes, dependent: :nullify

  pg_search_scope :search, against: :email, using: { tsearch: { prefix: true } }

  def gravity_user
    if defined?(@gravity_user)
      @gravity_user
    else
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
    gravity_user.try(:name)
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
    User.find_or_create_by(gravity_user_id: 'anonymous')
  end
end
