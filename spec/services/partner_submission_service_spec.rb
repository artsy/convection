require 'rails_helper'
require 'support/gravity_helper'

describe PartnerSubmissionService do
  describe '#daily_batch' do
    before do
      allow(Convection.config).to receive(:consignment_communication_id).and_return('comm1')
    end

    it 'does not create any partner submissions if there are no approved submissions' do
      Fabricate(:submission, state: 'submitted')
      PartnerSubmissionService.daily_batch
      expect(PartnerSubmission.count).to eq 0
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    it 'does not create any partner submissions if there are no partners to send to' do
      submission = Fabricate(:submission, state: 'approved')
      PartnerSubmissionService.daily_batch
      expect(PartnerSubmission.count).to eq 0
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
      expect(submission.state).to eq 'approved'
    end

    context 'with some submissions' do
      before do
        @partner = Fabricate(:partner, external_partner_id: 'partnerid')
        stub_gravity_root
        stub_gravity_artist
        stub_gravity_partner(name: 'Juliens Auctions')
        Fabricate(:submission, state: 'submitted')
        @approved1 = Fabricate(:submission,
          state: 'approved',
          artist_id: 'artistid',
          title: 'First approved artwork',
          year: '1992')
        @approved2 = Fabricate(:submission,
          state: 'approved',
          artist_id: 'artistid',
          title: 'Second approved artwork',
          year: '1993')
        @approved3 = Fabricate(:submission,
          state: 'approved',
          artist_id: 'artistid',
          title: 'Third approved artwork',
          year: '1997')
        Fabricate(:submission, state: 'rejected')
      end

      context 'with no partner contacts' do
        before do
          stub_gravity_partner_contacts(override_body: [])
        end

        it 'skips sending to partner if there are no partner contacts' do
          PartnerSubmissionService.daily_batch
          expect(PartnerSubmission.count).to eq 0
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 0
          expect(@approved1.reload.state).to eq 'approved'
          expect(@approved2.reload.state).to eq 'approved'
          expect(@approved3.reload.state).to eq 'approved'
        end
      end

      context 'with some partner contacts' do
        before do
          stub_gravity_partner_contacts
        end

        it 'sends an email batch to a single partner with only approved submissions' do
          PartnerSubmissionService.daily_batch
          expect(PartnerSubmission.count).to eq 3
          expect(@approved1.partner_submissions.count).to eq 1
          expect(@approved2.partner_submissions.count).to eq 1
          expect(@approved3.partner_submissions.count).to eq 1
          expect(@partner.partner_submissions.count).to eq 3

          expect(@approved1.reload.state).to eq 'visible'
          expect(@approved2.reload.state).to eq 'visible'
          expect(@approved3.reload.state).to eq 'visible'

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email = emails.first
          expect(email.subject).to include('Artsy Submission Batch for: Juliens Auctions')
          expect(email.html_part.body).to include('<i>First approved artwork</i><span>, 1992</span>')
          expect(email.html_part.body).to include('<i>Second approved artwork</i><span>, 1993</span>')
          expect(email.html_part.body).to include('<i>Third approved artwork</i><span>, 1997</span>')
        end

        it 'sends an email batch to multiple partners' do
          partner2 = Fabricate(:partner, external_partner_id: 'phillips')
          stub_gravity_partner(name: 'Phillips Auctions', id: 'phillips')
          stub_gravity_partner_contacts(partner_id: 'phillips')
          PartnerSubmissionService.daily_batch

          expect(@approved1.partner_submissions.count).to eq 2
          expect(@approved2.partner_submissions.count).to eq 2
          expect(@approved3.partner_submissions.count).to eq 2
          expect(@partner.partner_submissions.count).to eq 3
          expect(partner2.partner_submissions.count).to eq 3

          expect(@approved1.reload.state).to eq 'visible'
          expect(@approved2.reload.state).to eq 'visible'
          expect(@approved3.reload.state).to eq 'visible'

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          email = emails.first
          expect(email.html_part.body).to include('<i>First approved artwork</i><span>, 1992</span>')
          expect(email.html_part.body).to include('<i>Second approved artwork</i><span>, 1993</span>')
          expect(email.html_part.body).to include('<i>Third approved artwork</i><span>, 1997</span>')
        end

        it 'sends to only one partner if only one has partner contacts' do
          contactless_partner = Fabricate(:partner, external_partner_id: 'phillips')
          stub_gravity_partner(name: 'Phillips Auctions', id: 'phillips')
          stub_gravity_partner_contacts(partner_id: 'phillips', override_body: [])
          PartnerSubmissionService.daily_batch

          expect(@approved1.partner_submissions.count).to eq 1
          expect(@approved2.partner_submissions.count).to eq 1
          expect(@approved3.partner_submissions.count).to eq 1
          expect(contactless_partner.partner_submissions.count).to eq 0
          expect(@partner.partner_submissions.count).to eq 3

          expect(@approved1.reload.state).to eq 'visible'
          expect(@approved2.reload.state).to eq 'visible'
          expect(@approved3.reload.state).to eq 'visible'

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email = emails.first
          expect(email.subject).to include('Artsy Submission Batch for: Juliens Auctions')
          expect(email.html_part.body).to include('<i>First approved artwork</i><span>, 1992</span>')
          expect(email.html_part.body).to include('<i>Second approved artwork</i><span>, 1993</span>')
          expect(email.html_part.body).to include('<i>Third approved artwork</i><span>, 1997</span>')
        end
      end
    end
  end
end
