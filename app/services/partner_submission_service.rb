class PartnerSubmissionService
  class << self
    def daily_digest
      Partner.all.each do |partner|
        deliver_digest(partner.id)
      end
    end

    def deliver_digest(partner_id)
      partner = Partner.find(partner_id)
      partner_submissions = partner.partner_submissions.where(notified_at: nil)
      submissions = Submission.find(partner_submissions.pluck(:submission_id))

      if submissions.empty?
        $stderr.puts("Skipping digest for #{partner_id}... no submissions.")
        return
      end

      gravity_partner_id = partner.gravity_partner_id
      partner = Gravity.client.partner(id: gravity_partner_id)._get
      partner_communication = Gravity.client.partner_communications(
        name: Convection.config.consignment_communication_name
      ).first
      partner_contacts = Gravity.fetch_all(
        partner_communication,
        :partner_contacts,
        partner_id: gravity_partner_id
      )

      if !partner_contacts.any?
        $stderr.puts("Skipping digest for #{partner_id}... no partner contacts.")
        return
      end
      # partner_emails = partner_contacts.map(&:email)

      $stderr.puts("Sending digest of #{submissions.count} submissions to #{partner_contacts.count} contacts for partner #{partner_id} (#{partner.gravity_partner_id}).")
      PartnerMailer.submission_digest(
        submissions: submissions,
        partner: partner
        # partner_emails: partner_emails
      ).deliver_now

      notified_at = Time.now.utc
      partner_submissions.each { |ps| ps.update_attributes!(notified_at: notified_at) }
    end

    def generate_for_all_partners(submission_id)
      submission = Submission.find(submission_id)
      Partner.all.each do |partner|
        partner.partner_submissions.create!(submission: submission)
      end
    end

    def generate_for_new_partner(partner)
      Submission.where(state: 'approved').each do |submission|
        partner.partner_submissions.find_or_create_by!(submission_id: submission.id)
      end
    end
  end
end
