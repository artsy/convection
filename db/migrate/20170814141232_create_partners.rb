class CreatePartners < ActiveRecord::Migration[5.0]
  def change
    create_table :partners do |t|
      t.string :external_partner_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
