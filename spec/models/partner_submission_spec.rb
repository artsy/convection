require 'rails_helper'
require 'support/gravity_helper'

describe PartnerSubmission do
  let(:partner_submission) { Fabricate(:partner_submission) }

  context 'state' do
    it 'allows only certain states' do
      expect(PartnerSubmission.new(state: 'blah')).not_to be_valid
      expect(PartnerSubmission.new(state: 'open')).to be_valid
      expect(PartnerSubmission.new(state: 'canceled')).to be_valid
    end

    it 'sets the default to open' do
      expect(partner_submission.state).to eq 'open'
    end
  end

  context 'reference_id' do
    it 'generates a reference id when creating the object' do
      expect(partner_submission.reference_id).to_not be_nil
    end
  end

  context 'currency' do
    it 'allows only certain currencies' do
      expect(PartnerSubmission.new(currency: 'blah')).not_to be_valid
      expect(PartnerSubmission.new(currency: 'USD')).to be_valid
      expect(PartnerSubmission.new(currency: 'EUR')).to be_valid
      expect(PartnerSubmission.new(currency: 'GBP')).to be_valid
    end
  end

  context 'deletion' do
    it 'deletes associated offers, but not the submission' do
      Fabricate(:offer, submission: partner_submission.submission, partner_submission: partner_submission)
      expect do
        partner_submission.destroy
      end
        .to change { Submission.count }.by(0)
                                       .and change { Offer.count }.by(-1)
    end
  end
end
