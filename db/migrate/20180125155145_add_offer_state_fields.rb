class AddOfferStateFields < ActiveRecord::Migration[5.1]
  def change
    add_column :offers, :introduced_at, :datetime
    add_column :offers, :introduced_by, :string
    add_column :offers, :consigned_at, :datetime
  end
end
