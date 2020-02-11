class AddUsersTable < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :gravity_user_id, null: false
      t.string :email

      t.timestamps
    end

    add_index :users, %i[gravity_user_id], unique: true
  end
end
