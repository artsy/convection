# frozen_string_literal: true

class AdminUser < ApplicationRecord
  has_many :submissions,
           dependent: :nullify,
           inverse_of: :created_by,
           foreign_key: 'created_by_id'

  validates :gravity_user_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  scope :assignees, -> { where(assignee: true) }
  scope :cataloguers, -> { where(cataloguer: true) }
end
