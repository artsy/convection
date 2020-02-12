# frozen_string_literal: true

class AddOfferStateFields < ActiveRecord::Migration[5.1]
  def change
    add_column :offers, :review_started_at, :datetime
    add_column :offers, :consigned_at, :datetime
  end
end
