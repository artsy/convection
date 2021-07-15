# frozen_string_literal: true

class CreateAdminUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_users do |t|
      t.string :name, index: { unique: true }
      t.string :gravity_user_id, index: { unique: true }
      t.boolean :super_admin, index: true, default: false
      t.boolean :admin, index: true, default: false
      t.boolean :cataloguer, index: true, default: false

      t.timestamps
    end
  end
end
