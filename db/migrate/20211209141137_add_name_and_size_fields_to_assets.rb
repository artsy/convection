class AddNameAndSizeFieldsToAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :assets, :name, :string
    add_column :assets, :size, :string
  end
end
