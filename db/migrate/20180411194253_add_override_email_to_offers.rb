# frozen_string_literal: true

class AddOverrideEmailToOffers < ActiveRecord::Migration[5.1]
  def change
    add_column :offers, :override_email, :string
  end
end
