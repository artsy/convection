# frozen_string_literal: true

class AddPublisherToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :publisher, :string
  end
end
