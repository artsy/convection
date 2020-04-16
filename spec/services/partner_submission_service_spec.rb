# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe PartnerSubmissionService do
  before do
    @user = Fabricate(:user, gravity_user_id: 'userid')
    @user2 = Fabricate(:user, gravity_user_id: 'userid2')
    stub_gravity_root
    stub_gravity_user
    stub_gravity_user(id: 'userid2')
    stub_gravity_user_detail(id: 'userid2')
    stub_gravity_user_detail
    stub_gravity_artist
    stub_gravity_partner_communications
    stub_gravity_partner_contacts
    allow(Time).to receive(:now).and_return(
      Time.new(2_017, 9, 27).in_time_zone('UTC')
    ) # stub time for email subject lines
    allow(Convection.config).to receive(:auction_offer_form_url).and_return(
      'https://google.com/auction'
    )
  end

  describe '#generate_for_new_partner' do
    it 'generates partner submissions if the partner has no existing partner submissions' do
      submission = Fabricate(:submission, state: 'published')
      Fabricate(:submission, state: 'submitted')
      partner = Fabricate(:partner)
      PartnerSubmissionService.generate_for_new_partner(partner)
      expect(partner.partner_submissions.count).to eq 1
      expect(
        PartnerSubmission.where(submission: submission, partner: partner).count
      ).to eq 1
    end

    it 'generates new partner submissions' do
      partner = Fabricate(:partner)
      submission =
        Fabricate(
          :submission,
          state: 'submitted', user: @user, artist_id: 'artistid'
        )
      expect(NotificationService).to receive(:post_submission_event).once.with(
        submission.id,
        'published'
      )
      SubmissionService.update_submission(submission, state: 'published')
      expect(partner.partner_submissions.count).to eq 1
      expect(partner.partner_submissions.first.submission).to eq submission
      Fabricate(:submission, state: 'published')
      PartnerSubmissionService.generate_for_new_partner(partner)
      expect(partner.partner_submissions.count).to eq 2
    end
  end

  describe '#generate_for_all_partners' do
    it 'generates a new partner submission for a single partner' do
      submission = Fabricate(:submission, state: 'approved')
      partner = Fabricate(:partner)
      PartnerSubmissionService.generate_for_all_partners(submission.id)
      expect(partner.partner_submissions.count).to eq 1
    end

    it 'does nothing if there are no partners' do
      submission = Fabricate(:submission, state: 'approved')
      expect {
        PartnerSubmissionService.generate_for_all_partners(submission.id)
      }.to_not change(PartnerSubmission, :count)
    end
  end

  describe '#daily_digest' do
    before { stub_gravity_partner(name: 'Juliens Auctions') }

    it 'does not send any emails if there are no partner submissions' do
      Fabricate(:partner, gravity_partner_id: 'partnerid')
      Fabricate(:submission, state: 'approved')
      PartnerSubmissionService.daily_digest
      expect(PartnerSubmission.count).to eq 0
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    it 'does not send any emails if there are no partners' do
      Fabricate(:submission, state: 'approved')
      PartnerSubmissionService.daily_digest
      expect(PartnerSubmission.count).to eq 0
      emails = ActionMailer::Base.deliveries
      expect(emails.length).to eq 0
    end

    context 'with one submission with a minimum price' do
      before do
        @partner = Fabricate(:partner, gravity_partner_id: 'partnerid')
        Fabricate(:submission, state: 'submitted')
        @approved1 =
          Fabricate(
            :submission,
            state: 'submitted',
            artist_id: 'artistid',
            user: @user,
            title: 'Approved artwork with minimum price',
            year: '1992',
            minimum_price_cents: 50_000_00,
            currency: 'USD'
          )
        expect(NotificationService).to receive(:post_submission_event).once
          .with(@approved1.id, 'published')
        SubmissionService.update_submission(@approved1, state: 'published')
        PartnerSubmissionService.daily_digest
        @email = ActionMailer::Base.deliveries.last
      end

      it 'properly formats the price' do
        expect(@email.html_part.body).to include('Looking for: $50,000')
      end
    end

    context 'with one submission without a minimum price' do
      before do
        @partner = Fabricate(:partner, gravity_partner_id: 'partnerid')
        Fabricate(:submission, state: 'submitted')
        @approved1 =
          Fabricate(
            :submission,
            state: 'submitted',
            artist_id: 'artistid',
            user: @user,
            title: 'Approved artwork with minimum price',
            year: '1992'
          )
        expect(NotificationService).to receive(:post_submission_event).once
          .with(@approved1.id, 'published')
        SubmissionService.update_submission(@approved1, state: 'published')
      end

      it 'does not display any min price-related text' do
        PartnerSubmissionService.daily_digest
        email = ActionMailer::Base.deliveries.last
        expect(email.html_part.body).to_not include('Looking for:')
      end
    end

    context 'with some submissions' do
      before do
        @partner = Fabricate(:partner, gravity_partner_id: 'partnerid')
        Fabricate(:submission, state: 'submitted')
        @approved1 =
          Fabricate(
            :submission,
            state: 'submitted',
            artist_id: 'artistid',
            user: @user,
            title: 'First approved artwork',
            year: '1992'
          )
        @approved2 =
          Fabricate(
            :submission,
            state: 'submitted',
            artist_id: 'artistid',
            user: @user2,
            title: 'Second approved artwork',
            year: '1993'
          )
        @approved3 =
          Fabricate(
            :submission,
            state: 'submitted',
            artist_id: 'artistid',
            user: @user,
            title: 'Third approved artwork',
            year: '1997'
          )
        Fabricate(:submission, state: 'rejected')
        expect(NotificationService).to receive(:post_submission_event).once
          .with(@approved1.id, 'published')
        expect(NotificationService).to receive(:post_submission_event).once
          .with(@approved2.id, 'published')
        expect(NotificationService).to receive(:post_submission_event).once
          .with(@approved3.id, 'published')
        SubmissionService.update_submission(@approved1, state: 'published')
        SubmissionService.update_submission(@approved2, state: 'published')
        SubmissionService.update_submission(@approved3, state: 'published')
        ActionMailer::Base.deliveries = []
        expect(@partner.partner_submissions.count).to eq 3
      end

      context 'with no partner contacts' do
        before { stub_gravity_partner_contacts(override_body: []) }

        it 'skips sending to partner if there are no partner contacts' do
          PartnerSubmissionService.daily_digest
          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 0
          expect(PartnerSubmission.all.map(&:notified_at).compact).to eq []
        end
      end

      context 'with some partner contacts' do
        it 'sends an email digest to a single partner with only approved submissions' do
          PartnerSubmissionService.daily_digest

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email = emails.first
          expect(email.subject).to include(
            'New Artsy Consignments September 27: 3 works'
          )
          expect(email.bcc).to eq(%w[consignments-archive@artsymail.com])
          expect(email.from).to eq(%w[consign@artsy.net])
          expect(email.html_part.body).to include(
            '<i>First approved artwork</i><span>, 1992</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Second approved artwork</i><span>, 1993</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Third approved artwork</i><span>, 1997</span>'
          )
          expect(email.html_part.body).to include('https://google.com/auction')
          expect(
            @partner.partner_submissions.map(&:notified_at).compact.length
          ).to eq 3
        end

        it 'sends an email digest to multiple partner contacts with only approved submissions' do
          stub_gravity_partner_contacts(
            override_body: [
              { email: 'contact1@partner.com' },
              { email: 'contact2@partner.com' }
            ]
          )
          PartnerSubmissionService.daily_digest

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          expect(emails.map(&:to)).to include(
            %w[contact1@partner.com],
            %w[contact2@partner.com]
          )
        end

        it 'sends a digest with the first processed image' do
          first_image = Fabricate(:image, submission: @approved1)
          PartnerSubmissionService.daily_digest

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          expect(emails.first.html_part.body).to include(
            first_image.image_urls['square']
          )
        end

        it 'sends a digest with the primary image' do
          Fabricate(:image, submission: @approved1)
          second_image = Fabricate(:image, submission: @approved1)
          @approved1.update!(primary_image_id: second_image.id)
          PartnerSubmissionService.daily_digest

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          expect(emails.first.html_part.body).to include(
            second_image.image_urls['square']
          )
        end

        it 'includes links to additional images' do
          first_image = Fabricate(:image, submission: @approved1)
          Fabricate(
            :image,
            submission: @approved1,
            image_urls: {
              'square' => 'http://square1.jpg', 'large' => 'http://foo1.jpg'
            }
          )
          Fabricate(
            :image,
            submission: @approved1,
            image_urls: {
              'square' => 'http://square2.jpg', 'large' => 'http://foo2.jpg'
            }
          )
          Fabricate(
            :image,
            submission: @approved1,
            image_urls: {
              'square' => 'http://square3.jpg', 'large' => 'http://foo3.jpg'
            }
          )
          PartnerSubmissionService.daily_digest

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email_body = emails.first.html_part.body
          expect(email_body).to include(first_image.image_urls['square'])
          expect(email_body).to include(
            '<a href="http://foo1.jpg" style="color: #000001;">Image 2</a>'
          )
          expect(email_body).to include(
            '<a href="http://foo2.jpg" style="color: #000001;">Image 3</a>'
          )
          expect(email_body).to include(
            '<a href="http://foo3.jpg" style="color: #000001;">Image 4</a>'
          )
        end

        it 'displays the consignor information lines' do
          PartnerSubmissionService.daily_digest
          emails = ActionMailer::Base.deliveries
          email_body = emails.first.html_part.body
          expect(email_body.decoded.scan(/Consignor \d+/).size).to eq 2
          expect(email_body).to include('2 works')
          expect(email_body).to include('1 work')
        end

        it 'sends an email digest to multiple partners' do
          partner2 = Fabricate(:partner, gravity_partner_id: 'phillips')
          PartnerSubmissionService.generate_for_new_partner(partner2)
          stub_gravity_partner(name: 'Phillips Auctions', id: 'phillips')
          stub_gravity_partner_contacts(partner_id: 'phillips')
          PartnerSubmissionService.daily_digest

          expect(@approved1.partner_submissions.count).to eq 2
          expect(@approved2.partner_submissions.count).to eq 2
          expect(@approved3.partner_submissions.count).to eq 2
          expect(@partner.partner_submissions.count).to eq 3
          expect(partner2.partner_submissions.count).to eq 3

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 2
          email = emails.first
          expect(email.html_part.body).to include(
            '<i>First approved artwork</i><span>, 1992</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Second approved artwork</i><span>, 1993</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Third approved artwork</i><span>, 1997</span>'
          )
        end

        it 'sends to only one partner if only one has partner contacts' do
          contactless_partner =
            Fabricate(:partner, gravity_partner_id: 'phillips')
          stub_gravity_partner(name: 'Phillips Auctions', id: 'phillips')
          stub_gravity_partner_contacts(
            partner_id: 'phillips', override_body: []
          )
          PartnerSubmissionService.daily_digest

          expect(@approved1.partner_submissions.count).to eq 1
          expect(@approved2.partner_submissions.count).to eq 1
          expect(@approved3.partner_submissions.count).to eq 1
          expect(contactless_partner.partner_submissions.count).to eq 0
          expect(@partner.partner_submissions.count).to eq 3

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email = emails.first
          expect(email.subject).to include(
            'New Artsy Consignments September 27: 3 works'
          )
          expect(email.html_part.body).to include(
            '<i>First approved artwork</i><span>, 1992</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Second approved artwork</i><span>, 1993</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Third approved artwork</i><span>, 1997</span>'
          )
        end

        it 'sends to a gallery partner' do
          gallery_partner = Fabricate(:partner, gravity_partner_id: 'gagosian')
          stub_gravity_partner(
            name: 'Gagosian Gallery', id: 'gagosian', type: 'Gallery'
          )
          stub_gravity_partner_contacts(
            partner_id: 'gagosian', override_body: []
          )
          PartnerSubmissionService.generate_for_new_partner(gallery_partner)
          PartnerSubmissionService.deliver_digest(gallery_partner.id)

          expect(gallery_partner.partner_submissions.count).to eq 3

          emails = ActionMailer::Base.deliveries
          expect(emails.length).to eq 1
          email = emails.first
          expect(email.subject).to include(
            'New Artsy Consignments September 27: 3 works'
          )
          expect(email.html_part.body).to_not include('Submit Proposal')
          expect(email.html_part.body).to include(
            'Please respond directly to this email with your proposal, or if you have any questions'
          )
          expect(email.html_part.body).to include(
            '<i>First approved artwork</i><span>, 1992</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Second approved artwork</i><span>, 1993</span>'
          )
          expect(email.html_part.body).to include(
            '<i>Third approved artwork</i><span>, 1997</span>'
          )
        end
      end
    end
  end
end
