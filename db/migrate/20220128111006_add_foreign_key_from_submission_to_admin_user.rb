class AddForeignKeyFromSubmissionToAdminUser < ActiveRecord::Migration[6.1]
  def up
    add_column :submissions, :admin_id, :bigint
    add_foreign_key :submissions, :admin_users, column: :admin_id

    populate_admin_id_field

    remove_column :submissions, :created_by, :string
  end

  def down
    add_column :submissions, :created_by, :string

    populate_created_by_field_with_email

    remove_foreign_key :submissions, :admin_users, column: :admin_id
    remove_column :submissions, :admin_id, :bigint
  end

  def populate_admin_id_field
    Submission.all.select { |x| !x[:created_by].blank? }.each do |submission|
      user = AdminUser.find_by(email: submission[:created_by])

      submission.update(admin_id: user.id) unless user.nil?
    end
  end

  def populate_created_by_field_with_email
    Submission
      .where
      .not(admin_id: nil)
      .each do |submission|
        user = AdminUser.find_by(id: submission.admin_id)

        unless user.nil?
          submission[:created_by] = user.email
          submission.save!
        end
      end
  end
end
