class CreateArtistAppraisalRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :artist_appraisal_ratings do |t|
      t.string :artist_id
      t.float :score
      t.timestamps
    end
  end
end
