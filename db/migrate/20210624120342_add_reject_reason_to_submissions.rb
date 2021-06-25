class AddRejectReasonToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :rejection_reason, :string
  end
end
