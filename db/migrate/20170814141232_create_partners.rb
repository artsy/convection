class CreatePartners < ActiveRecord::Migration[5.0]
  def change
    create_table :partners do |t|
      t.string :external_partner_id, null: false
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
