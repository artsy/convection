# frozen_string_literal: true

namespace :admins do
  desc 'Create admins and cataloguers from constants'
  task create: :environment do
    ADMINS.each do |id, name|
      admin = Admin.find_by(gravity_user_id: id)

      if admin && !admin.admin
        admin.update(admin: true)
      end

      unless admin
        Admin.create!(gravity_user_id: id, name: name, admin: true)
      end
    end

    CATALOGUERS.each do |id, name|
      admin = Admin.find_by(gravity_user_id: id)

      if admin && !admin.cataloguer
        admin.update(cataloguer: true)
      end

      unless admin
        Admin.create!(gravity_user_id: id, name: name, cataloguer: true)
      end
    end
  end
end
