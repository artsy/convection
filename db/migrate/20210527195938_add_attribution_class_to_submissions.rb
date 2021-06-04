# frozen_string_literal: true

class AddAttributionClassToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :attribution_class, :integer
  end
end
