# frozen_string_literal: true

class AddDemandScoresToEstimate < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :artist_score, :float
    add_column :submissions, :auction_score, :float
  end
end
