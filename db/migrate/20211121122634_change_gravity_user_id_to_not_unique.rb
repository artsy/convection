# frozen_string_literal: true

class ChangeGravityUserIdToNotUnique < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, [:gravity_user_id]
    add_index :users, [:gravity_user_id], unique: false
  end
end
