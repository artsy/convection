class PartnerSubmissionService
  class << self
    def daily_batch
      submissions = Submission.where(state: 'approved')
      partners = Partner.all
      partners.each do |partner|
        delay.deliver_daily_batch(submissions, partner)
      end
    end

    def deliver_daily_batch(submissions, partner)
      gravity_partner_id = partner.external_partner_id
      partner_name = Gravity.client.partner(id: gravity_partner_id).name
      partner_contacts = Gravity.client.partner_contacts(
        partner_id: gravity_partner_id,
        communication_id: Convection.config.consignment_communication_id
      )
      return unless partner_contacts.count.positive?
      # partner_emails = partner_contacts.map(&:email)

      PartnerMailer.submission_batch(
        submissions: submissions,
        partner_name: partner_name
        # partner_emails: partner_emails
      ).deliver_now

      record_partner_submissions(submissions, partner)
    end

    def record_partner_submissions(submissions, partner)
      submissions.each do |submission|
        submission.partner_submissions.create!(partner: partner)
        submission.update_attributes!(state: 'visible')
      end
    end
  end
end
