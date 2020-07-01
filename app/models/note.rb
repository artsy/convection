# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission

  attr_reader :author

  after_initialize :set_author

  def set_author
    @author ||= load_author # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  private

  def load_author
    return nil unless gravity_user_id

    Gravity.client.user(id: gravity_user_id)._get
  rescue Faraday::ResourceNotFound
    nil
  end
end
