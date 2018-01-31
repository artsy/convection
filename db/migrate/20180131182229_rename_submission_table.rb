class RenameSubmissionTable < ActiveRecord::Migration[5.1]
  def change
    rename_column :submissions, :user_id, :ext_user_id

    add_reference :submissions, :user, foreign_key: true, type: :integer
  end
end
