# frozen_string_literal: true

module PartnerUpdateService
  class << self
    def update_partners_from_gravity
      Partner.all.each { |partner| delay.update_partner!(partner.id) }
    end

    def update_partner!(partner_id)
      partner = Partner.find_by(id: partner_id)
      if partner.blank?
        Rails.logger.info "No partner found for #{partner_id}"
        return
      end

      gravity_partner = Gravity.client.partner(id: partner.gravity_partner_id)
      new_partner_name = gravity_partner.name
      unless partner.name == new_partner_name
        partner.update!(name: new_partner_name)
      end
    end
  end
end
