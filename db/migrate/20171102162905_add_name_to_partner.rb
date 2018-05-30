class AddNameToPartner < ActiveRecord::Migration[5.0]
  def change
    add_column :partners, :name, :string
  end
end
