class AddLocationAddressToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :location_address, :string, null: true
    add_column :submissions, :location_address2, :string, null: true
  end
end
