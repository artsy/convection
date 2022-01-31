# frozen_string_literal: true

namespace :admin_user do
  task :load_admins_emails => :environment do
    puts "Admins email addresses loading started."

    AdminUser.all.find_each do |admin_user|
      next if admin_user.email.present?

      user = (
        begin
            Gravity.client.user(id: admin_user.gravity_user_id).user_detail._get
        rescue Faraday::ResourceNotFound
          puts "Can't find user with the id: #{admin_user.gravity_user_id}."
          nil
        end
      )

      if user&.email.blank? 
        puts "Can't find email for the user: #{admin_user.gravity_user_id}."
        next
      end

      admin_user.email = user&.email
      admin_user.save!
    end

    puts "Admins email addresses loading finished."
  end
end
