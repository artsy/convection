# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :submission
  belongs_to :author, foreign_key: :created_by, class_name: "User", inverse_of: :authored_notes
end
