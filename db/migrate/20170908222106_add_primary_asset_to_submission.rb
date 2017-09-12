class AddPrimaryAssetToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :primary_asset_id, :integer
  end
end
