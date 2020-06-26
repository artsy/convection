# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission
  belongs_to :author, foreign_key: :created_by, class_name: "User", inverse_of: :authored_notes

  def byline
    (author ? "#{author.email} - " : '') + \
    (created_at == updated_at ? '' : 'Updated ') + \
    updated_at.to_formatted_s(:long)
  end
end
