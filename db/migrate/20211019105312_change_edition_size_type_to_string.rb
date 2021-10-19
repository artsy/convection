# frozen_string_literal: true

class ChangeEditionSizeTypeToString < ActiveRecord::Migration[6.1]
  def self.up
    change_table :submissions do |t|
      t.change :edition_size, :string
    end
  end

  def self.down
    change_table :submissions do |t|
      t.change :edition_size, :integer
    end
  end
end
