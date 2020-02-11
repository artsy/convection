# frozen_string_literal: true

class AddOffersTable < ActiveRecord::Migration[5.0]
  def change
    create_table :offers do |t|
      t.references :partner_submission, foreign_key: true, index: true
      t.string :offer_type
      t.datetime :sale_period_start
      t.datetime :sale_period_end
      t.datetime :sale_date
      t.string :sale_name
      t.integer :low_estimate_cents
      t.integer :high_estimate_cents
      t.string :currency
      t.text :notes
      t.float :commission_percent
      t.integer :price_cents
      t.integer :shipping_cents
      t.integer :photography_cents
      t.integer :other_fees_cents
      t.float :other_fees_percent
      t.float :insurance_percent
      t.float :insurance_cents
      t.string :state
      t.string :created_by_id
      t.string :reference_id, index: true
      t.timestamps
    end
  end
end
