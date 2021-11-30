class RemoveCreatedByFromSubmissions < ActiveRecord::Migration[6.1]
  def change
    remove_column :submissions, :createdBy, :string
  end
end
