# frozen_string_literal: true

class AddExhibitionToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :exhibition, :string
  end
end
