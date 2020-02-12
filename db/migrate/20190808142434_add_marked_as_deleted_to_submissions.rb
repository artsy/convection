# frozen_string_literal: true

class AddMarkedAsDeletedToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :deleted_at, :datetime
  end
end
