class AddPrimaryAssetToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_reference :submissions, :primary_image, references: :assets, index: true
    add_foreign_key :submissions, :assets, column: :primary_image_id
  end
end
