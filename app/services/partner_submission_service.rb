class PartnerSubmissionService
  class << self
    def daily_batch
      Partner.all.each do |partner|
        delay.deliver_partner_batch(partner.id)
      end
    end

    def deliver_partner_batch(partner_id)
      partner = Partner.find(partner_id)
      partner_submissions = partner.partner_submissions.where(notified_at: nil)
      submissions = Submission.find(partner_submissions.pluck(:submission_id))
      return if submissions.empty?

      gravity_partner_id = partner.gravity_partner_id
      partner_name = Gravity.client.partner(id: gravity_partner_id).name
      partner_contacts = Gravity.client.partner_contacts(
        partner_id: gravity_partner_id,
        communication_id: Convection.config.consignment_communication_id
      )
      return unless partner_contacts.any?
      # partner_emails = partner_contacts.map(&:email)

      PartnerMailer.submission_batch(
        submissions: submissions,
        partner_name: partner_name
        # partner_emails: partner_emails
      ).deliver_now

      partner_submissions.each { |ps| ps.update_attributes!(notified_at: Time.now.utc) }
    end

    def generate_for_all_partners(submission_id)
      submission = Submission.find(submission_id)
      Partner.all.each do |partner|
        partner.partner_submissions.create!(submission: submission)
      end
    end

    def generate_for_new_partner(partner)
      existing_submission_ids = partner.partner_submissions.where(notified_at: nil).pluck(:submission_id)
      new_submission_ids = Submission.where(state: 'approved').pluck(:id) - existing_submission_ids
      Submission.find(new_submission_ids).each do |submission|
        partner.partner_submissions.create!(submission: submission)
      end
    end
  end
end
