# frozen_string_literal: true

task :exchange_assigned_to_real_user => :environment do
  Submission.all.find_each do |submission|
    submission.exchange_assigned_to_real_user!
  end
end

task :rebase_user_submission => :environment do
  User.all.find_each do |user|
    if user.user_submissions.count > 1
      # try to find submission with same creditals(gravity_id or email,phone,name) and id
      user_submissions = user.user_submissions.select {|submission| submission.user.id == user.id}
      # delete from result already assigned submission
      user_submissions.delete(user.submission)
      # dublicate user and assign submission
      user_submissions&.each do |user_submission|
        dup_user = user.dup
        dup_user.submission = user_submission
        dup_user.save!
      end
    end
  end
end
