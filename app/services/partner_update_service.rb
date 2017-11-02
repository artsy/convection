module PartnerUpdateService
  class << self
    def update_partners_from_gravity
      Partner.all.each do |partner|
        delay.update_partner!(partner.id)
      end
    end

    def update_partner!(partner_id)
      partner = Partner.find_by(id: partner_id)
      if partner.blank?
        Rails.logger.info "No partner found for #{partner_id}"
        return
      end

      gravity_partner = Gravity.client.partner(id: partner.gravity_partner_id)
      new_partner_name = gravity_partner.name
      partner.update_attributes!(name: new_partner_name) unless partner.name == new_partner_name
    end
  end
end
