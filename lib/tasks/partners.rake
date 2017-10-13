namespace :partners do
  desc 'Sends daily email to partners with newly approved submissons.'
  task daily_digest: :environment do
    puts "[#{Time.now}] Generating daily partner digest for #{Partner.count} partners ..."
    PartnerSubmissionService.daily_digest
  end
end
