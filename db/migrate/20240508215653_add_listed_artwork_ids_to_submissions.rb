class AddListedArtworkIdsToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :listed_artwork_ids, :string, array: true, null: false, default: []
  end
end
