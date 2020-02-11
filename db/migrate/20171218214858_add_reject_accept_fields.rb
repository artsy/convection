# frozen_string_literal: true

class AddRejectAcceptFields < ActiveRecord::Migration[5.0]
  def change
    add_column :offers, :rejection_reason, :string
    add_column :offers, :rejection_note, :text
    add_column :offers, :rejected_by, :string
    add_column :offers, :rejected_at, :datetime

    add_column :offers, :accepted_by, :string
    add_column :offers, :accepted_at, :datetime
  end
end
