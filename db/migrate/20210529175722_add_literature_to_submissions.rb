# frozen_string_literal: true

class AddLiteratureToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :literature, :string
  end
end
