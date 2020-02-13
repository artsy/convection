# frozen_string_literal: true

class AddSubmissionIdToOffer < ActiveRecord::Migration[5.0]
  def change
    add_reference :offers, :submission, index: true
    add_foreign_key :offers, :submissions
  end
end
