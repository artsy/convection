# frozen_string_literal: true

namespace :partners do
  desc 'Sends daily email to partners with newly approved submissons.'
  task daily_digest: :environment do
    puts "[#{Time.now.utc}] Generating daily partner digest for #{Partner.count} partners ..."
    PartnerSubmissionService.daily_digest
  end

  task update: :environment do
    puts "[#{Time.now.utc}] Updating partners ..."
    PartnerUpdateService.update_partners_from_gravity
  end
end
