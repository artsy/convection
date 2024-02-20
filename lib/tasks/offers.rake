# frozen_string_literal: true

namespace :offers do
  desc "Lapse all offers that were sent before a certain date"
  task :lapse_sent, [:date] => :environment do |_task, args|
    raise "Please supply a date until which sent offers should be considered to lapse!" unless args[:date]

    datetime = args[:date].to_datetime
    Offer.where("state = ? AND (sent_at < ? OR sent_at IS NULL)", "sent", datetime).update_all(state: "lapsed")
  end

  desc "Lapse all offers that were reviewed before a certain date"
  task :lapse_review, [:date] => :environment do |_task, args|
    raise "Please supply a date until which reviewed offers should be considered to lapse!" unless args[:date]

    datetime = args[:date].to_datetime
    Offer.where("state = ? AND review_started_at < ?", "review", datetime).update_all(state: "lapsed")
  end
end
