# frozen_string_literal: true

class AddStartingBidCentsToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :starting_bid_cents, :bigint
  end
end
