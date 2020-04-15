# frozen_string_literal: true

class PartnerSubmissionService
  class PartnerSubmissionError < StandardError; end

  class << self
    def daily_digest
      Partner.all.each { |partner| delay.deliver_digest(partner.id) }
    end

    def deliver_digest(partner_id)
      partner = Partner.find(partner_id)
      partner_submissions = partner.partner_submissions.where(notified_at: nil)
      ids = partner_submissions.pluck(:submission_id)
      submissions = Submission.where(state: Submission::PUBLISHED, id: ids)

      if submissions.empty?
        Rails.logger.info "Skipping digest for #{partner_id}... no submissions."
        return
      end

      gravity_partner_id = partner.gravity_partner_id
      gravity_partner = Gravity.client.partner(id: gravity_partner_id)._get
      partner_communication =
        Gravity.client.partner_communications(
          name: Convection.config.consignment_communication_name
        ).first
      partner_contacts =
        Gravity.fetch_all(
          partner_communication,
          :partner_contacts,
          partner_id: gravity_partner_id
        )

      unless partner_contacts.any?
        Rails.logger.info "Skipping digest for #{
                            partner_id
                          }... no partner contacts."
        return
      end

      Rails.logger.info(
        "Sending digest of #{submissions.count} submissions to partner #{
          partner_id
        } (#{partner.gravity_partner_id})."
      )

      submission_ids = submissions.pluck(:id)
      partner_contacts.map(&:email).each do |email|
        delay.deliver_partner_contact_email(
          submission_ids,
          partner.name,
          gravity_partner.type,
          email
        )
      end

      notified_at = Time.now.utc
      partner_submissions.each { |ps| ps.update!(notified_at: notified_at) }
    end

    def deliver_partner_contact_email(
      submission_ids, partner_name, partner_type, email
    )
      submissions = Submission.find(submission_ids)
      return if submissions.empty?

      users_to_submissions = submissions.group_by(&:user)
      PartnerMailer.submission_digest(
        users_to_submissions: users_to_submissions,
        partner_name: partner_name,
        partner_type: partner_type,
        email: email,
        submissions_count: submissions.count
      ).deliver_now
    end

    def generate_for_all_partners(submission_id)
      submission = Submission.find(submission_id)
      Partner.all.each do |partner|
        partner.partner_submissions.create!(submission: submission)
      end
    end

    def generate_for_new_partner(partner)
      Submission.where(state: 'published').each do |submission|
        partner.partner_submissions.find_or_create_by!(
          submission_id: submission.id
        )
      end
    end
  end
end
