module PartnerService
  class << self
    def fetch_partner_contacts!(partner)
      gravity_partner_id = partner.gravity_partner_id
      partner_communication = Gravity.client.partner_communications(
        name: Convection.config.consignment_communication_name
      ).first

      partner_contacts = Gravity.fetch_all(
        partner_communication,
        :partner_contacts,
        partner_id: gravity_partner_id
      )

      raise "No contacts for #{partner.id}" unless partner_contacts.any?

      partner_contacts.map(&:email)
    end
  end
end
