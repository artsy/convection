# frozen_string_literal: true

class AddMyCollectionArtworkIdFieldToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submission, :my_collection_artwork_id, :string
  end
end
