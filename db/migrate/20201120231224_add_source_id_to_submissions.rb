# frozen_string_literal: true

class AddSourceIdToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :source_artwork_id, :string
  end
end
