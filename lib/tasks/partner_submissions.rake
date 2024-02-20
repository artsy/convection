# frozen_string_literal: true

namespace :partner_submissions do
  desc "Cancel all consignments that were open before a certain date"
  task :cancel_open, [:date] => :environment do |_task, args|
    raise "Please supply a date until which open consignments should be considered to canceled!" unless args[:date]

    datetime = args[:date].to_datetime
    PartnerSubmission.consigned.where("state = ? AND created_at < ?", "open", datetime).update_all(state: "canceled")
  end
end
