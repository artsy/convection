# frozen_string_literal: true

class AddSessionIdToUserAndSetGravityIdNullable < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      change_table :users do |t|
        dir.up do
          t.change :gravity_user_id, :string, null: true
          t.string :session_id, null: true
        end

        dir.down do
          t.change :gravity_user_id, :string, null: false
          t.remove :session_id
        end
      end
    end
  end
end
