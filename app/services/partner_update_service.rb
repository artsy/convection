require 'csv'

module PartnerUpdateService
  class << self
    def update_partners_from_gravity
      Partner.all.each do |partner|
        delay.update_partner_from_gravity(partner.id)
      end
    end

    def update_partner_from_gravity(partner_id)
      partner = Partner.find(partner_id)
      gravity_partner = Gravity.client.partner(id: partner.gravity_partner_id)._get
      update_partner!(partner_id, gravity_partner.name)
    end

    def update_partner!(partner_id, new_partner_name)
      partner = Partner.find(partner_id)
      if partner.name == new_partner_name
        Rails.logger.info "Skipping updating #{new_partner_name}: Name already up-to-date."
      else
        Rails.logger.info "Updating #{partner.name} to #{new_partner_name}."
        partner.update_attributes!(name: new_partner_name)
      end
    end
  end
end
