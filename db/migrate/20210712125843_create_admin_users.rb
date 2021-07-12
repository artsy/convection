class CreateAdminUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_users do |t|
      t.string :name
      t.string :gravity_user_id
      t.boolean :admin, index: true, default: false
      t.boolean :cataloguer, index: true, default: false

      t.timestamps
    end
  end
end
