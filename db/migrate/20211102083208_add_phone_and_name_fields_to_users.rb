# frozen_string_literal: true

class AddPhoneAndNameFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :name
      t.string :phone
    end
  end
end
