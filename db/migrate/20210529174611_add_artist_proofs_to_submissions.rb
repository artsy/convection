# frozen_string_literal: true

class AddArtistProofsToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :artist_proofs, :string
  end
end
