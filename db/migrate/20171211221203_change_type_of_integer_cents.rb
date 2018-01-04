class ChangeTypeOfIntegerCents < ActiveRecord::Migration[5.0]
  def change
    change_column :offers, :insurance_cents, :integer
  end
end
