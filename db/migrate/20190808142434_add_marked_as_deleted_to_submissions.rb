class AddMarkedAsDeletedToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :marked_as_deleted, :boolean
  end
end
