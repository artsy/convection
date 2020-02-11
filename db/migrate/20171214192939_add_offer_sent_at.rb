# frozen_string_literal: true

class AddOfferSentAt < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :sent_at, :datetime
    add_column :offers, :sent_by, :string
  end
end
