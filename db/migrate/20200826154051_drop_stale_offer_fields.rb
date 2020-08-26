# frozen_string_literal: true

class DropStaleOfferFields < ActiveRecord::Migration[6.0]
  def change
    change_table :offers, bulk: true do
      remove_column :offers, :accepted_at, :datetime
      remove_column :offers, :accepted_by, :string
    end
  end
end
