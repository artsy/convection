class AddForeignKeyFromSubmissionToAdminUser < ActiveRecord::Migration[6.1]
  def up
    add_column :submissions, :created_by_id, :bigint
    add_foreign_key :submissions, :admin_users, column: :created_by_id

    populate_created_by_field_with_admin_id

    remove_column :submissions, :created_by, :string
  end

  def down
    add_column :submissions, :created_by, :string

    populate_created_by_field_with_email

    remove_foreign_key :submissions, :admin_users, column: :created_by_id
    remove_column :submissions, :created_by_id, :bigint
  end

  def populate_created_by_id_field_with_admin_id
    Submission.all.select { |x| !x[:created_by].blank? }.each do |submission|
      user = AdminUser.find_by(email: submission[:created_by])

      submission.update(created_by_id: user.id) unless user.nil?
    end
  end

  def populate_created_by_field_with_email
    Submission
      .where
      .not(created_by_id: nil)
      .each do |submission|
        user = AdminUser.find_by(id: submission.created_by_id)

        unless user.nil?
          submission[:created_by] = user.email
          submission.save!
        end
      end
  end
end
