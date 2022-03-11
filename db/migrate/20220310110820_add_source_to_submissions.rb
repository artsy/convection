class AddSourceToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :source, :string
  end
end
