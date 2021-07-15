# frozen_string_literal: true

class CreateAdminUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_users do |t|
      t.string :name, index: { unique: true }, default: false
      t.string :gravity_user_id, index: { unique: true }, default: false
      t.boolean :super_admin, index: true
      t.boolean :admin, index: true
      t.boolean :cataloguer, index: true

      t.timestamps
    end
  end
end
