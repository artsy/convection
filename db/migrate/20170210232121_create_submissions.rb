class CreateSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :submissions do |t|
      t.integer :user_id, index: true
      t.boolean :qualified
      t.datetime :delivered_at
      t.string :artist_id
      t.string :title
      t.string :medium
      t.string :year
      t.string :category
      t.string :height
      t.string :width
      t.string :depth
      t.string :dimensions_metric
      t.boolean :signature
      t.boolean :authenticity_certificate
      t.text :provenance
      t.string :location_city
      t.string :location_state
      t.string :location_country
      t.date :deadline_to_sell
      t.text :additional_info
      t.timestamps
    end

    create_table :assets do |t|
      t.string :asset_type
      t.string :gemini_token
      t.string :image_urls
    end
  end
end
