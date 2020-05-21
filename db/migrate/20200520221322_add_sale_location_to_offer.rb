class AddSaleLocationToOffer < ActiveRecord::Migration[6.0]
  def change
    add_column :offers, :sale_location, :string
  end
end
