class AddS3BucketAndPathToAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :assets, :s3_bucket, :string, null: true
    add_column :assets, :s3_path, :string, null: true
  end
end
