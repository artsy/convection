require 'rails_helper'
require 'support/gravity_helper'

describe OfferService do
  let!(:user) { Fabricate(:user) }
  let(:submitted_submission) { Fabricate(:submission, state: 'submitted') }
  let(:submission) { Fabricate(:submission, state: 'approved') }
  let(:draft_submission) { Fabricate(:submission) }
  let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }

  context 'create_offer' do
    describe 'with a submission in submitted state' do
      it 'updates the submission state to approved' do
        OfferService.create_offer(submitted_submission.id, partner.id, {}, user.id)
        expect(submitted_submission.reload.state).to eq 'approved'
        expect(submitted_submission.reload.approved_by).to eq user.id.to_s
        expect(submitted_submission.reload.approved_at).to_not be_nil
      end
    end
    describe 'with a submission in a draft state' do
      it 'raises an error' do
        expect{ OfferService.create_offer(draft_submission.id, partner.id, {}, user.id) }.to raise_error do |error|
          expect(error).to be_a OfferService::OfferError
          expect(error.message).to eq 'Cannot create offer on draft submission'          
        end
      end
    end
    describe 'with no initial partner submission' do
      it 'creates a draft offer' do
        expect(PartnerSubmission.where(submission: submission, partner: partner).count).to eq 0
        OfferService.create_offer(submission.id, partner.id)
        expect(PartnerSubmission.where(submission: submission, partner: partner).count).to eq 1
        ps = PartnerSubmission.where(submission: submission, partner: partner).first
        expect(ps.offers.count).to eq 1
        expect(ps.offers.first.state).to eq 'draft'
        expect(ps.notified_at).to_not be_nil
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
      stub_gravity_user(id: offer.submission.user.gravity_user_id)
      stub_gravity_user_detail(email: 'michael@bluth.com', id: offer.submission.user.gravity_user_id)
      stub_gravity_artist(id: submission.artist_id)
      stub_gravity_partner(id: partner.gravity_partner_id)
      stub_gravity_partner_communications(partner_id: partner.gravity_partner_id)
      stub_gravity_partner_contacts(
        partner_id: partner.gravity_partner_id,
        override_body: [
          { email: 'contact1@partner.com' },
          { email: 'contact2@partner.com' }
        ]
      )
      allow(Convection.config).to receive(:offer_response_form_url).and_return('https://google.com/response_form?entry.1=SUBMISSION_NUMBER&entry.2=PARTNER_NAME')
      allow(Convection.config).to receive(:auction_offer_form_url).and_return('https://google.com/offer_form?entry.1=SUBMISSION_NUMBER')
    end

    describe 'sending an offer' do
      it 'sends an email to a user with offer information' do
        OfferService.update_offer(offer, 'userid', state: 'sent')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 1
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.first.to).to eq(['michael@bluth.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(emails.first.subject).to eq('An offer for your consignment submission')

        email_body = emails.first.html_part.body
        expect(email_body).to include(
          'Great news, an offer has been made for your work.'
        )
        expect(email_body).to include('The work will be purchased directly from you by the partner')
        expect(email_body).to include('Happy Gallery')
        expect(email_body).to include("https://google.com/response_form?entry.1=#{submission.id}&amp;entry.2=Happy%20Gallery")
        expect(offer.reload.state).to eq 'sent'
        expect(offer.sent_by).to eq 'userid'
        expect(offer.sent_at).to_not be_nil
      end

      it 'does not send an email if the email has already been sent' do
        offer.update!(sent_at: Time.now.utc)
        OfferService.update_offer(offer, 'userid', state: 'sent')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 0
      end
    end

    describe 'introducing an offer' do
      it 'sends an email saying the user is interested in the offer' do
        OfferService.update_offer(offer, 'userid', state: 'review')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.map(&:to).flatten).to eq(['contact1@partner.com', 'contact2@partner.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(emails.first.subject).to eq('The consignor has expressed interest in your offer')
        expect(emails.first.html_part.body).to include(
          'Your offer has been reviewed, and the consignor has expressed interest your offer'
        )
        expect(emails.first.html_part.body).to include('Happy Gallery')
        expect(emails.first.html_part.body).to_not include('The work will be purchased directly from you by the partner')
        expect(offer.reload.state).to eq 'review'
        expect(offer.review_started_at).to_not be_nil
      end
    end

    describe 'consigning an offer' do
      context 'with an offer on a non-approved submission' do
        it 'raises an error' do
          expect{ OfferService.update_offer(offer, 'userid', state: 'consigned') }.to raise_error do |error|
            expect(error).to be_a OfferService::OfferError
            expect(error.message).to eq 'Cannot complete consignment on non-approved submission'
          end
        end
      end
      context 'with an offer on an approved submission' do
        let(:approved_submission) { Fabricate(:submission, state: Submission::APPROVED) }
        let(:ps) { Fabricate(:partner_submission, submission: approved_submission) }
        let(:consignable_offer) { Fabricate(:offer, partner_submission: ps) }
        it 'sets fields on submission and partner submission' do
          OfferService.update_offer(consignable_offer, 'userid', state: 'consigned')
          expect(ActionMailer::Base.deliveries.count).to eq 0
          expect(ps.state).to eq 'open'
          expect(ps.accepted_offer).to eq consignable_offer
          expect(ps.partner_commission_percent).to eq consignable_offer.commission_percent
          expect(ps.submission.consigned_partner_submission).to eq consignable_offer.partner_submission
          expect(consignable_offer.consigned_at).to_not be_nil
        end
      end
    end

    describe 'rejecting an offer' do
      it 'sends an email saying the offer has been rejected' do
        OfferService.update_offer(offer, 'userid', state: 'rejected')
        emails = ActionMailer::Base.deliveries
        expect(emails.length).to eq 2
        expect(emails.first.bcc).to eq(['consignments-archive@artsymail.com'])
        expect(emails.map(&:to).flatten).to eq(['contact1@partner.com', 'contact2@partner.com'])
        expect(emails.first.from).to eq(['consign@artsy.net'])
        expect(emails.first.subject).to eq('A response to your consignment offer')

        email_body = emails.first.html_part.body
        expect(email_body).to include(
          'Your offer has been reviewed, and the consignor has rejected your offer.'
        )
        expect(email_body).to include('Happy Gallery')
        expect(email_body).to_not include('The work will be purchased directly from you by the partner')
        expect(email_body).to include("https://google.com/offer_form?entry.1=#{submission.id}")
        expect(offer.reload.state).to eq 'rejected'
        expect(offer.rejected_by).to eq 'userid'
        expect(offer.rejected_at).to_not be_nil
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
