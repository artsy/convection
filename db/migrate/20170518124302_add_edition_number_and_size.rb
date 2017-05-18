class AddEditionNumberAndSize < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :edition_number, :string
    add_column :submissions, :edition_size, :integer
  end
end
