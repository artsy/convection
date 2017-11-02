require 'rails_helper'
require 'support/gravity_helper'

describe PartnerUpdateService do
  describe '#update_partners_from_gravity' do
    let!(:partner1) { Fabricate(:partner, gravity_partner_id: 'phillips', name: 'Phillips') }
    let!(:partner2) { Fabricate(:partner, gravity_partner_id: 'gagosian', name: 'Gagosian Gallery') }
    let!(:partner3) { Fabricate(:partner, gravity_partner_id: 'pace', name: 'Pace Gallery') }

    before do
      stub_gravity_root
      stub_gravity_partner(id: 'phillips', name: 'Phillips New')
      stub_gravity_partner(id: 'gagosian', name: 'Gagosian Gallery')
      stub_gravity_partner(id: 'pace', name: 'Pace Gallery')
    end

    it 'updates partners if they have a new name' do
      PartnerUpdateService.update_partners_from_gravity
      expect(partner1.reload.name).to eq 'Phillips New'
      expect(partner2.reload.name).to eq 'Gagosian Gallery'
      expect(partner3.reload.name).to eq 'Pace Gallery'
    end
  end
end
