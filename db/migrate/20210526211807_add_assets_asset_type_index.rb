# frozen_string_literal: true

class AddAssetsAssetTypeIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :assets, %i[submission_id asset_type]
  end
end
