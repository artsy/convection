class AddPostalCodeToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :location_postal_code, :string
  end
end
