# frozen_string_literal: true

class AddCataloguerToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :cataloguer, :string
  end
end
