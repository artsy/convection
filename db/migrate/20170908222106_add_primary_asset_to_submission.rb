class AddPrimaryAssetToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_reference :submissions, :primary_asset, foreign_key: { to_table: :assets }
  end
end
