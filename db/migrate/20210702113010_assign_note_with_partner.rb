# frozen_string_literal: true

class AssignNoteWithPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :notes, :assign_with_partner, :boolean
  end
end
