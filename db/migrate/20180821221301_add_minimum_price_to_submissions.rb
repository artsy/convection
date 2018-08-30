class AddMinimumPriceToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :minimum_price_cents, :bigint
    add_column :submissions, :currency, :string
  end
end
