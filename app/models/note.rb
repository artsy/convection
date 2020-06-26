# frozen_string_literal: true

class Note < ApplicationRecord
  validates :body, presence: true
  belongs_to :submission

  belongs_to :author,
             foreign_key: :gravity_user_id,
             class_name: 'User',
             primary_key: :gravity_user_id
end
