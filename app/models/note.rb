# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission

  def author
    @author ||= load_author
  end

  private

  def load_author
    return nil unless gravity_user_id

    Gravity.client.user(id: gravity_user_id)._get
  rescue Faraday::ResourceNotFound
    nil
  end
end
