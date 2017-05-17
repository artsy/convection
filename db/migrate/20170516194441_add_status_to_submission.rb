class AddStatusToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :edition, :boolean
    add_column :submissions, :status, :string
    add_column :submissions, :receipt_sent_at, :datetime
  end
end
