# frozen_string_literal: true

class AddAssignedToToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :assigned_to, :string
  end
end
