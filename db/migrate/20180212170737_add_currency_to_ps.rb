class AddCurrencyToPs < ActiveRecord::Migration[5.1]
  def change
    rename_column :partner_submissions, :sale_currency, :currency
  end
end
