class AddCountryCodeToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :location_country_code, :string
  end
end
