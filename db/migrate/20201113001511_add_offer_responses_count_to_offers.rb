# frozen_string_literal: true

class AddOfferResponsesCountToOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :offers, :offer_responses_count, :integer
  end
end
