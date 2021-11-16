# frozen_string_literal: true

class AddSessionIdToUser < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :session_id
    end
  end
end
