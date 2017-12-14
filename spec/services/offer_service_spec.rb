require 'rails_helper'

describe OfferService do
  let(:submission) { Fabricate(:submission, state: 'approved') }
  let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }

  context 'create_offer' do
    describe 'with no initial partner submission' do
      it 'creates a draft offer' do
        expect(PartnerSubmission.where(submission: submission, partner: partner).count).to eq 0
        OfferService.create_offer(submission.id, partner.id)
        expect(PartnerSubmission.where(submission: submission, partner: partner).count).to eq 1
        ps = PartnerSubmission.where(submission: submission, partner: partner).first
        expect(ps.offers.count).to eq 1
        expect(ps.offers.first.state).to eq 'draft'
      end
    end

    describe 'with an initial partner submission' do
      before do
        @partner_submission = Fabricate(:partner_submission, partner: partner, submission: submission)
      end

      it 'creates multiple draft offers' do
        OfferService.create_offer(submission.id, partner.id)
        expect(@partner_submission.offers.count).to eq 1
        expect(@partner_submission.offers.first.state).to eq 'draft'

        OfferService.create_offer(submission.id, partner.id)
        expect(@partner_submission.offers.count).to eq 2
        expect(@partner_submission.offers.pluck(:state).uniq).to eq ['draft']
      end

      it 'fails if the partner does not exist' do
        expect do
          OfferService.create_offer(submission.id, 'blah')
        end.to raise_error(OfferService::OfferError)
      end

      it 'fails if the submission does not exist' do
        expect do
          OfferService.create_offer('blah', partner.id)
        end.to raise_error(OfferService::OfferError)
      end

      it 'fails if no partner_id param is passed' do
        expect do
          OfferService.create_offer(submission.id, nil)
        end.to raise_error(OfferService::OfferError)
      end

      it 'fails if no submission_id param is passed' do
        expect do
          OfferService.create_offer(nil, partner.id)
        end.to raise_error(OfferService::OfferError)
      end
    end
  end

  context 'update_offer' do
    it 'updates the offer with the new params' do
      offer = Fabricate(:offer,
        low_estimate_cents: 10_000,
        high_estimate_cents: 20_000,
        commission_percent: 10,
        offer_type: 'auction consignment')
      OfferService.update_offer(offer, high_estimate_cents: 30_000, notes: 'New offer notes!')
      expect(offer.reload.high_estimate_cents).to eq 30_000
      expect(offer.reload.notes).to eq 'New offer notes!'
    end

    it 'raises an error if validation fails' do
      offer = Fabricate(:offer,
        low_estimate_cents: 10_000,
        high_estimate_cents: 20_000,
        commission_percent: 10,
        offer_type: 'auction consignment')
      expect do
        OfferService.update_offer(offer, offer_type: 'non-valid-type')
      end.to raise_error(OfferService::OfferError)
    end
  end
end
