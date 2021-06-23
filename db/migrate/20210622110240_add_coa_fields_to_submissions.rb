# frozen_string_literal: true

class AddCoaFieldsToSubmissions < ActiveRecord::Migration[6.1]
  def change
    change_table :submissions, bulk: true do |t|
      t.boolean :coa_by_authenticating_body
      t.boolean :coa_by_gallery
    end
  end
end
