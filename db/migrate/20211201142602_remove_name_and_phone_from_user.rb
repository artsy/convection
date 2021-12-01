class RemoveNameAndPhoneFromUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      #remove_column :users, :name, :string
      #remove_column :users, :phone, :string
      remove_column :users, :session_id, :string
    end
    change_table :submissions, bulk: true do |t|
      t.string :session_id
    end
  end
end
