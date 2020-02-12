class AddPartnerInfoToOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :offers, :partner_info, :text
  end
end
