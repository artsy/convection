class AddCreatedByToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :created_by, :string
  end
end
