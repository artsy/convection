# frozen_string_literal: true

class AddColumnsToSubmission < ActiveRecord::Migration[6.1]
  def change
    change_table :submissions, bulk: true do |t|
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_term
    end
  end
end
