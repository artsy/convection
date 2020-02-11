# frozen_string_literal: true

class AddPartnerSubmission < ActiveRecord::Migration[5.0]
  def change
    create_table :partner_submissions do |t|
      t.references :submission, foreign_key: true, index: true
      t.references :partner, foreign_key: true, index: true
      t.datetime :notified_at
      t.timestamps
    end

    rename_column :partners, :external_partner_id, :gravity_partner_id
  end
end
