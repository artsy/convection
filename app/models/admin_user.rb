# frozen_string_literal: true

class AdminUser < ApplicationRecord
  validates :gravity_user_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  scope :assignees, -> { where(assignee: true) }
  scope :cataloguers, -> { where(cataloguer: true) }
end
