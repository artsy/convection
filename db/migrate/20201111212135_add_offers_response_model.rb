# frozen_string_literal: true

class AddOffersResponseModel < ActiveRecord::Migration[6.0]
  def change
    create_table :offer_responses do |t|
      t.references :offer, foreign_key: true, index: true
      t.string :intended_state, null: false
      t.string :phone_number
      t.text :comments
      t.string :rejection_reason
      t.timestamps
    end
  end
end
