# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission
  belongs_to :user

  def author
    if defined?(@author)
      @author
    else
      @author =
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
end
