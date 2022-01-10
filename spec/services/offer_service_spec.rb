# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe OfferService do
  let(:user) { Fabricate(:user, email: 'michael@bluth.com') }
  let(:partner) { Fabricate(:partner, name: 'Gagosian Gallery') }
  let(:submission) do
    Fabricate(:submission, state: submission_state, user: user)
  end

  before do
    allow_any_instance_of(PartnerMailer).to receive(:reply_email).and_return(
      'reply_email@artsy.net'
    )
  end

  describe 'create_offer' do
    context 'with an id for created by but no current user' do
      let(:submission_state) { Submission::APPROVED }

      it 'sets that id on the offer' do
        offer_params = { created_by_id: 'just-some-user-id' }

        offer =
          OfferService.create_offer(
            submission.id,
            partner.id,
            offer_params,
            nil
          )

        expect(offer.created_by_id).to eq offer_params[:created_by_id]
      end
    end

    context 'with a submission in submitted state' do
      let(:submission_state) { Submission::SUBMITTED }

      it 'updates the submission state to approved' do
        OfferService.create_offer(submission.id, partner.id, {}, user.id)

        submission.reload

        expect(submission.state).to eq Submission::APPROVED
        expect(submission.approved_by).to eq user.id.to_s
        expect(submission.approved_at).to_not be_nil
      end
    end

    context 'with a submission in a draft state' do
      let(:submission_state) { Submission::DRAFT }

      it 'updates the submission state to approved' do
        OfferService.create_offer(submission.id, partner.id, {}, user.id)

        submission.reload

        expect(submission.state).to eq Submission::APPROVED
        expect(submission.approved_by).to eq user.id.to_s
        expect(submission.approved_at).to_not be_nil
      end
    end

    context 'with a submission in a rejected state' do
      let(:submission_state) { Submission::REJECTED }

      it 'raises an error' do
        expect {
          OfferService.create_offer(submission.id, partner.id, {}, user.id)
        }.to raise_error(
          OfferService::OfferError,
          'Invalid submission state for offer creation'
        )
      end
    end

    context 'with no initial partner submission' do
      let(:submission_state) { Submission::APPROVED }

      it 'creates a draft offer and a partner submission' do
        expect {
          OfferService.create_offer(submission.id, partner.id)
        }.to change {
          PartnerSubmission.where(submission: submission, partner: partner)
            .count
        }.from(0).to(1)

        ps =
          PartnerSubmission.where(submission: submission, partner: partner)
            .first
        expect(ps.offers.count).to eq 1
        expect(ps.offers.first.state).to eq Offer::DRAFT
        expect(ps.notified_at).to_not be_nil
      end
    end

    context 'with an initial partner submission' do
      let!(:partner_submission) do
        Fabricate(:partner_submission, partner: partner, submission: submission)
      end
      let(:submission_state) { Submission::APPROVED }

      it 'creates multiple draft offers' do
        expect {
          OfferService.create_offer(submission.id, partner.id)
          OfferService.create_offer(submission.id, partner.id)
        }.to change { partner_submission.offers.count }.from(0).to(2)

        states = partner_submission.offers.pluck(:state)
        expect(states.uniq).to eq [Offer::DRAFT]
      end

      it 'fails if the partner does not exist' do
        expect {
          OfferService.create_offer(submission.id, 'blah')
        }.to raise_error(OfferService::OfferError)
      end

      it 'fails if the submission does not exist' do
        expect { OfferService.create_offer('blah', partner.id) }.to raise_error(
          OfferService::OfferError
        )
      end

      it 'fails if no partner_id param is passed' do
        expect { OfferService.create_offer(submission.id, nil) }.to raise_error(
          OfferService::OfferError
        )
      end

      it 'fails if no submission_id param is passed' do
        expect { OfferService.create_offer(nil, partner.id) }.to raise_error(
          OfferService::OfferError
        )
      end
    end
  end

  describe 'update_offer' do
    it 'updates the offer with the new params' do
      offer =
        Fabricate(
          :offer,
          low_estimate_cents: 10_000,
          high_estimate_cents: 20_000,
          commission_percent: 10,
          offer_type: 'auction consignment'
        )
      OfferService.update_offer(
        offer,
        'userid',
        high_estimate_cents: 30_000,
        notes: 'New offer notes!'
      )
      expect(offer.high_estimate_cents).to eq 30_000
      expect(offer.notes).to eq 'New offer notes!'
    end

    it 'raises an error if validation fails' do
      offer =
        Fabricate(
          :offer,
          low_estimate_cents: 10_000,
          high_estimate_cents: 20_000,
          commission_percent: 10,
          offer_type: 'auction consignment'
        )
      expect {
        OfferService.update_offer(offer, 'userid', offer_type: 'non-valid-type')
      }.to raise_error(OfferService::OfferError)
    end

    it 'sends no emails if the state has not been changed' do
      OfferService.update_offer(
        Fabricate(:offer),
        'userid',
        price_cents: 20_000
      )
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    context 'with an offer' do
      let(:partner) { Fabricate(:partner, name: 'Happy Gallery') }
      let(:submission_state) { Submission::DRAFT }
      let(:partner_submission) do
        Fabricate(:partner_submission, partner: partner, submission: submission)
      end
      let(:offer) do
        Fabricate(
          :offer,
          offer_type: 'purchase',
          price_cents: 10_000,
          state: Offer::DRAFT,
          partner_submission: partner_submission,
          sale_location: 'Marrakesh, Morocco'
        )
      end

      before do
        add_default_stubs(
          id: offer.submission.user.gravity_user_id,
          artist_id: submission.artist_id
        )
        stub_gravity_partner(id: partner.gravity_partner_id)
        stub_gravity_partner_communications(
          partner_id: partner.gravity_partner_id
        )
        stub_gravity_partner_contacts(
          partner_id: partner.gravity_partner_id,
          override_body: [
            { email: 'contact1@partner.com' },
            { email: 'contact2@partner.com' }
          ]
        )
        allow(Convection.config).to receive(:offer_response_form_url)
          .and_return(
          'https://google.com/response_form?entry.1=SUBMISSION_NUMBER&entry.2=PARTNER_NAME'
        )
        allow(Convection.config).to receive(:auction_offer_form_url).and_return(
          'https://google.com/offer_form?entry.1=SUBMISSION_NUMBER'
        )
      end

      context 'sending an offer' do
        it 'sends an email to a user with offer information' do
          OfferService.update_offer(offer, 'userid', state: Offer::SENT)
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
          expect(emails.first.to).to eq(%w[michael@bluth.com])
          expect(emails.first.from).to eq(%w[consign@artsy.net])
          expect(emails.first.subject).to eq('An Offer for your Artwork')

          email_body = emails.first.html_part.body
          expect(email_body).to include(
            'We are delighted to share an offer to sell your artwork.'
          )
          expect(email_body).to include(
            'The work will be purchased directly from you by the partner'
          )
          expect(email_body).to include('Happy Gallery')
          expect(email_body).to include(
            "https://google.com/response_form?entry.1=#{
              submission.id
            }&amp;entry.2=Happy%20Gallery"
          )
          expect(email_body).to include('Marrakesh, Morocco')

          offer.reload

          expect(offer.state).to eq Offer::SENT
          expect(offer.sent_by).to eq 'userid'
          expect(offer.sent_at).to_not be_nil
        end

        it 'does not send an email if the email has already been sent' do
          offer.update!(sent_at: Time.now.utc)
          OfferService.update_offer(offer, 'userid', state: Offer::SENT)
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 0
        end
      end

      context 'does not send an offer email' do
        it 'does not send an email to a user if the state is saved' do
          OfferService.update_offer(offer, 'userid', state: Offer::SAVED)
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 0

          offer.reload

          expect(offer.state).to eq Offer::SAVED
          expect(offer.sent_by).to be_nil
          expect(offer.sent_at).to be_nil
        end
      end

      context 'introducing an offer' do
        it 'sends an email saying the user is interested in the offer' do
          OfferService.update_offer(offer, 'userid', state: Offer::REVIEW)
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
          expect(emails.map(&:to).flatten).to eq(
            %w[contact1@partner.com contact2@partner.com]
          )
          expect(emails.first.reply_to).to eq(%w[reply_email@artsy.net])
          expect(emails.first.from).to eq(%w[consign@artsy.net])
          expect(emails.first.subject).to eq(
            'The consignor has expressed interest in your offer'
          )
          expect(emails.first.html_part.body).to include(
            'Your offer has been reviewed, and the consignor has expressed interest your offer'
          )
          expect(emails.first.html_part.body).to include('Happy Gallery')
          expect(emails.first.html_part.body).to_not include(
                                                       'The work will be purchased directly from you by the partner'
                                                     )
          expect(offer.state).to eq Offer::REVIEW
          expect(offer.review_started_at).to_not be_nil
        end
      end

      context 'consigning an offer' do
        context 'with an offer on a non-approved submission' do
          it 'raises an error' do
            expect {
              OfferService.update_offer(offer, 'userid', state: Offer::ACCEPTED)
            }.to raise_error(
              OfferService::OfferError,
              'Cannot complete consignment on non-approved submission'
            )
          end
        end
        context 'with an offer on an approved submission' do
          let(:submission_state) { Submission::APPROVED }

          let(:ps) { Fabricate(:partner_submission, submission: submission) }
          let(:consignable_offer) { Fabricate(:offer, partner_submission: ps) }
          it 'sets fields on submission and partner submission' do
            OfferService.update_offer(
              consignable_offer,
              'userid',
              state: Offer::ACCEPTED
            )
            expect(ActionMailer::Base.deliveries.count).to eq 0
            expect(ps.state).to eq 'open'
            expect(ps.accepted_offer).to eq consignable_offer
            expect(ps.partner_commission_percent).to eq consignable_offer
                 .commission_percent
            expect(
              ps.submission.consigned_partner_submission
            ).to eq consignable_offer.partner_submission
            expect(consignable_offer.consigned_at).to_not be_nil
          end
        end
      end

      context 'rejecting an offer' do
        it 'sends an email saying the offer has been rejected' do
          OfferService.update_offer(offer, 'userid', state: Offer::REJECTED)
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          expect(emails.first.bcc).to eq(%w[consignments-archive@artsymail.com])
          expect(emails.map(&:to).flatten).to eq(
            %w[contact1@partner.com contact2@partner.com]
          )
          expect(emails.first.from).to eq(%w[consign@artsy.net])
          expect(emails.first.reply_to).to eq(%w[reply_email@artsy.net])
          expect(emails.first.subject).to eq(
            'A response to your consignment offer'
          )

          email_body = emails.first.html_part.body
          expect(email_body).to include(
            'Your offer has been reviewed, and the consignor has rejected your offer.'
          )
          expect(email_body).to include('Happy Gallery')
          expect(email_body).to_not include(
                                      'The work will be purchased directly from you by the partner'
                                    )
          expect(email_body).to include(
            "https://google.com/offer_form?entry.1=#{submission.id}"
          )
          expect(offer.state).to eq Offer::REJECTED
          expect(offer.rejected_by).to eq 'userid'
          expect(offer.rejected_at).to_not be_nil
        end

        it 'does not set consignment-related fields on an offer rejecton' do
          OfferService.update_offer(offer, 'userid', state: Offer::REJECTED)
          ps = offer.partner_submission
          expect(ps.state).to eq 'open'
          expect(ps.accepted_offer_id).to be_nil
          expect(ps.partner_commission_percent).to be_nil
          expect(ps.submission.consigned_partner_submission).to be_nil
        end
      end

      context 'undoing offer rejection' do
        subject do
          OfferService.undo_rejection!(offer)
          offer.reload
        end

        let(:offer) do
          Fabricate(
            :offer,
            partner_submission: partner_submission,
            sale_location: 'Marrakesh, Morocco',
            state: Offer::REJECTED,
            rejected_by: 'userid',
            rejected_at: Time.now.utc,
            rejection_reason: 'Low estimate',
            rejection_note: 'Test Note'
          )
        end

        it { is_expected.to have_attributes({ state: Offer::SENT }) }

        it 'nullifies rejection related fields' do
          is_expected.to have_attributes(
            {
              rejected_by: nil,
              rejected_at: nil,
              rejection_reason: nil,
              rejection_note: nil
            }
          )
        end
      end

      context 'undo offer lapse' do
        subject do
          OfferService.undo_lapse!(offer)
          offer.reload
        end
        let(:offer) { Fabricate(:offer, state: Offer::LAPSED) }
        it { is_expected.to have_attributes({ state: Offer::SENT }) }
      end
    end
  end
end
