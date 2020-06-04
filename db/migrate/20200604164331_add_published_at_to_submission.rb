# frozen_string_literal: true

class AddPublishedAtToSubmission < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :published_at, :datetime
  end
end
