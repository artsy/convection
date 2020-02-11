# frozen_string_literal: true

class UseBigint < ActiveRecord::Migration[5.1]
  def change
    change_column :partner_submissions, :sale_price_cents, :bigint
    change_column :offers, :low_estimate_cents, :bigint
    change_column :offers, :high_estimate_cents, :bigint
    change_column :offers, :price_cents, :bigint
  end
end
