# frozen_string_literal: true

task :exchange_assigned_to_real_user => :environment do
  Submission.all.find_each do |submission|
    submission.exchange_assigned_to_real_user!
  end
end
    
task correction_seq_id: :environment do
  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end
end

task :rebase_user_submission => :environment do
  User.all.find_each do |user|
    # find all submissions with user_id like the user.id
    user_submissions = Submission.where(user_id: user.id)
    if user_submissions.count > 1
      # delete from result already assigned submission
      user_submissions = user_submissions.reject { |submission| submission == user.submission }
      user_submissions&.each do |user_submission|
        # create new user and assign submission
        new_user = User.create!(
          gravity_user_id: user.gravity_user_id,
          name: user[:name],
          email: user[:email],
          phone: user[:phone],
          session_id: user.session_id
        )
        new_user.submission = user_submission
        new_user.save!
      end
    end
  end
end
