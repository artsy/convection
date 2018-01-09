require 'rails_helper'
require 'support/gravity_helper'

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
      OfferService.update_offer(offer, 'userid', high_estimate_cents: 30_000, notes: 'New offer notes!')
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
        OfferService.update_offer(offer, 'userid', offer_type: 'non-valid-type')
      end.to raise_error(OfferService::OfferError)
    end

    it 'sends no emails if the state has not been changed' do
      OfferService.update_offer(Fabricate(:offer), 'userid', price_cents: 20_000)
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end
  end

  context 'with an offer' do
    let(:partner) { Fabricate(:partner, name: 'Happy Gallery') }
    let(:submission) { Fabricate(:submission) }
    let(:partner_submission) { Fabricate(:partner_submission, partner: partner, submission: submission) }
    let(:offer) { Fabricate(:offer, offer_type: 'purchase', price_cents: 10_000, state: 'draft', partner_submission: partner_submission) }

    before do
      stub_gravity_root
      stub_gravity_user(id: offer.submission.user_id)
      stub_gravity_user_detail(email: 'michael@bluth.com', id: offer.submission.user_id)
      stub_gravity_artist(id: submission.artist_id)
    end

    describe 'sending an offer' do
      it 'sends an email to a user with offer information' do
        OfferService.update_offer(offer, 'userid', state: 'sent')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.to).to eq([Convection.config.debug_email_address])
        expect(emails.first.html_part.body).to include(
          'Happy Gallery has sent you an offer'
        )
        expect(offer.reload.state).to eq 'sent'
        expect(offer.sent_by).to eq 'userid'
        expect(offer.sent_at).to_not be_nil
      end

      it 'does not send an email if the email has already been sent' do
        offer.update_attributes!(sent_at: Time.now.utc)
        OfferService.update_offer(offer, 'userid', state: 'sent')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end
    end

    describe 'accepting an offer' do
      it 'sends an email saying the offer has been accepted' do
        OfferService.update_offer(offer, 'userid', state: 'accepted')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.to).to eq([Convection.config.debug_email_address])
        expect(emails.first.html_part.body).to include(
          'We will connect you directly with the collector to complete this transaction.'
        )
        expect(offer.reload.state).to eq 'accepted'
        expect(offer.accepted_by).to eq 'userid'
        expect(offer.accepted_at).to_not be_nil
        expect(offer.rejected_by).to be_nil
        expect(offer.rejected_at).to be_nil
      end

      it 'sets fields on submission and partner submission' do
        OfferService.update_offer(offer, 'userid', state: 'accepted')
        ps = offer.partner_submission
        expect(ps.state).to eq 'unconfirmed'
        expect(ps.accepted_offer).to eq offer
        expect(ps.partner_commission_percent).to eq offer.commission_percent
        expect(ps.submission.consigned_partner_submission).to eq offer.partner_submission
      end
    end

    describe 'rejecting an offer' do
      it 'sends an email saying the offer has been rejected' do
        OfferService.update_offer(offer, 'userid', state: 'rejected')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.to).to eq([Convection.config.debug_email_address])
        expect(emails.first.html_part.body).to include(
          'The collector has rejected your offer. Sorry.'
        )
        expect(offer.reload.state).to eq 'rejected'
        expect(offer.rejected_by).to eq 'userid'
        expect(offer.rejected_at).to_not be_nil
        expect(offer.accepted_by).to be_nil
        expect(offer.accepted_at).to be_nil
      end

      it 'does not set consignment-related fields on an offer rejecton' do
        OfferService.update_offer(offer, 'userid', state: 'rejected')
        ps = offer.partner_submission
        expect(ps.state).to eq 'open'
        expect(ps.accepted_offer_id).to be_nil
        expect(ps.partner_commission_percent).to be_nil
        expect(ps.submission.consigned_partner_submission).to be_nil
      end
    end
  end
end
