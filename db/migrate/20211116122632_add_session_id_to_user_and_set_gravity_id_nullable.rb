# frozen_string_literal: true

class AddSessionIdToUserAndSetGravityIdNullable < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.change :gravity_user_id, :string, null: true
      t.string :session_id, null: true
    end
  end
end
