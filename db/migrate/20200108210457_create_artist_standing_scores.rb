class CreateArtistStandingScores < ActiveRecord::Migration[5.2]
  def change
    create_table :artist_standing_scores do |t|
      t.string :artist_id
      t.float :artist_score
      t.float :auction_score
      t.timestamps
    end
  end
end
