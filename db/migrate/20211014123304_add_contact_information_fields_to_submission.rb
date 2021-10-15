# frozen_string_literal: true

class AddContactInformationFieldsToSubmission < ActiveRecord::Migration[6.1]
  def change
    change_table :submissions, bulk: true do |t|
      t.string :user_name
      t.string :user_phone
    end
  end
end
