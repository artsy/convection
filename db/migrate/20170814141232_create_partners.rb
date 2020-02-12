# frozen_string_literal: true

class CreatePartners < ActiveRecord::Migration[5.0]
  def change
    create_table :partners do |t|
      t.string :external_partner_id, null: false

      t.timestamps
    end
    add_index :partners, %i[external_partner_id], unique: true
  end
end
