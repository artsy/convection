class AddApprovedByToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :submissions, :approved_by, :string
    add_column :submissions, :approved_at, :datetime
    add_column :submissions, :rejected_by, :string
    add_column :submissions, :rejected_at, :datetime
  end
end
