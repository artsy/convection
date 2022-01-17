class AddSourceArtworkIdIndexToSubmissionTable < ActiveRecord::Migration[6.1]
  def change
    add_index :submissions, :source_artwork_id
  end
end
