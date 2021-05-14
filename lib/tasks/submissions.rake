# frozen_string_literal: true

task :exchange_assigned_to_real_user => :environment do
  Submission.all.find_each do |submission|
    submission.exchange_assigned_to_real_user!
  end
end
