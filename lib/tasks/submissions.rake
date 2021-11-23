# frozen_string_literal: true

task :exchange_assigned_to_real_user => :environment do
  Submission.all.find_each do |submission|
    submission.exchange_assigned_to_real_user!
  end
end

task :rebase_user_submission => :environment do
  User.all.find_each do |user|
    user_submissions = Submission.where(user_id: user.id)
    if user_submissions.count > 1
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
