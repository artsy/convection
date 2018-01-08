require 'rails_helper'
require 'support/gravity_helper'

describe PartnerSubmission do
  let(:ps) { Fabricate(:partner_submission) }

  context 'state' do
    it 'allows only certain states' do
      expect(PartnerSubmission.new(state: 'blah')).not_to be_valid
      expect(PartnerSubmission.new(state: 'unconfirmed')).to be_valid
    end
  end

  context 'reference_id' do
    it 'generates a reference id when creating the object' do
      expect(ps.reference_id).to_not be_nil
    end
  end
end
