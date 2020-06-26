# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :gravity_user_id, null: false
      t.text :body, null: false
      t.references :submission, foreign_key: true

      t.timestamps
    end
  end
end
