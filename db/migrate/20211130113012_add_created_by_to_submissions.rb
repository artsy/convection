class AddCreatedByToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :createdBy, :string
  end
end
