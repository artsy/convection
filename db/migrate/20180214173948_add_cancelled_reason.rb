# frozen_string_literal: true

class AddCancelledReason < ActiveRecord::Migration[5.1]
  def change
    add_column :partner_submissions, :canceled_reason, :text
  end
end
