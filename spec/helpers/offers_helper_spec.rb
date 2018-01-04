require 'rails_helper'
require 'support/gravity_helper'

describe OffersHelper, type: :helper do
  context 'reviewed_byline' do
    before do
      stub_gravity_root
      stub_gravity_user
    end

    it 'shows the correct label for an accepted offer' do
      offer = Fabricate(:offer, state: 'accepted', accepted_by: 'userid')
      expect(helper.reviewed_byline(offer)).to eq 'Accepted by Jon Jonson.'
    end

    it 'shows the correct label for a rejected offer' do
      offer = Fabricate(:offer, state: 'rejected', rejected_by: 'userid')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by Jon Jonson.'
    end

    it 'shows the correct label for a rejected offer with a rejection_reason' do
      offer = Fabricate(:offer, state: 'rejected', rejected_by: 'userid', rejection_reason: 'Low estimate')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by Jon Jonson. Low estimate'
    end

    it 'shows the correct label for a rejected offer with a rejection_reason and rejection_note' do
      offer = Fabricate(:offer,
        state: 'rejected',
        rejected_by: 'userid',
        rejection_reason: 'Other',
        rejection_note: 'User not a fan of this partner.')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by Jon Jonson. Other: User not a fan of this partner.'
    end

    it 'shows the correct label for an accepted offer with no user' do
      offer = Fabricate(:offer, state: 'accepted')
      expect(helper.reviewed_byline(offer)).to eq 'Accepted by .'
    end

    it 'shows the correct label for a rejected offer with no user' do
      offer = Fabricate(:offer, state: 'rejected')
      expect(helper.reviewed_byline(offer)).to eq 'Rejected by .'
    end
  end
end
