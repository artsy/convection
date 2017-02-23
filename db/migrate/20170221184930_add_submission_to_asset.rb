class AddSubmissionToAsset < ActiveRecord::Migration[5.0]
  def change
    add_reference :assets, :submission, foreign_key: true
  end
end
