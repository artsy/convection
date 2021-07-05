# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission

  scope :notes_with_assigned_partner, -> { where(assign_with_partner: true).includes(:submission) }
  scope :partner_assigned_notes, -> (user_id) { notes_with_assigned_partner.select { |note| note.submission.user_id == user_id } }

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
