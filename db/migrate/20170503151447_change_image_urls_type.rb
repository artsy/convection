class ChangeImageUrlsType < ActiveRecord::Migration[5.0]
  def self.up
    change_column :assets, :image_urls, 'jsonb USING CAST(image_urls AS jsonb)', default: {}
  end

  def self.down
    change_column :assets, :image_urls, :string
  end
end
