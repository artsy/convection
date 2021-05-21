# frozen_string_literal: true

require 'rails_helper'

describe DashboardReportingQuery::Submission do
  context 'when no submission' do
    describe 'grouped_by_state' do
      subject { DashboardReportingQuery::Submission.grouped_by_state }
      it { is_expected.to eq({}) }
    end

    describe 'unreviewed_user_submissions' do
      subject { DashboardReportingQuery::Submission.unreviewed_user_submissions('user_id') }
      it { is_expected.to eq({self_assigned: 0, total: 0, unassigned: 0}) }
    end
  end

  context 'when submissions exist' do
    before do
      Fabricate(:submission, state: Submission::APPROVED, assigned_to: nil)
      Fabricate(:submission, state: Submission::SUBMITTED, assigned_to: nil)
      Fabricate(:submission, state: Submission::DRAFT,  assigned_to: 'user_id')
      Fabricate(:submission, state: Submission::SUBMITTED, assigned_to: 'user_id')
      Fabricate(:submission, state: Submission::SUBMITTED, assigned_to: 'user_id', deleted_at: Time.now.utc)
    end

    describe 'grouped_by_state' do
      subject { DashboardReportingQuery::Submission.grouped_by_state }
      it { is_expected.to include({ draft: 1, approved: 1, submitted: 2 }) }
    end

    describe 'unreviewed_user_submissions' do
      subject { DashboardReportingQuery::Submission.unreviewed_user_submissions('user_id') }
      it { is_expected.to include({total: 2, unassigned: 1, self_assigned: 1 }) }
    end
  end
end

describe DashboardReportingQuery::Offer do
  context 'when no offer' do
    describe 'grouped_by_state' do
      subject { DashboardReportingQuery::Offer.grouped_by_state }
      it { is_expected.to eq({ review: 0, sent: 0, total: 0 }) }
    end
  end

  context 'when offers exist' do
    before do
      Fabricate(:offer, state: Offer::DRAFT)
      Fabricate(:offer, state: Offer::SENT)
      Fabricate(:offer, state: Offer::REVIEW)
      Fabricate(:offer, state: Offer::REJECTED)
    end

    describe 'grouped_by_state' do
      subject { DashboardReportingQuery::Offer.grouped_by_state }
      it { is_expected.to include({ review: 1, sent: 1, total: 4 }) }
    end
  end
end


describe DashboardReportingQuery::Consignment do
  context 'when no consignment' do
    describe 'grouped_by_state_and_partner' do
      subject { DashboardReportingQuery::Consignment.grouped_by_state_and_partner }
      it { is_expected.to eq({}) }
    end
  end

  context 'when consignments exist' do
    before do
      @partner1 = Fabricate(:partner, name: 'Artsy')
      @partner2 = Fabricate(:partner, name: 'Heritage Auctions')
      @partner3 = Fabricate(:partner, name: 'Artsy x SomeGallery')

      Fabricate(:consignment, state: 'open', partner: @partner1)
      Fabricate(:consignment, state: 'sold', partner: @partner1)
      Fabricate(:consignment, state: 'canceled', partner: @partner1)
      Fabricate(:consignment, state: 'open', partner: @partner2)
      Fabricate(:consignment, state: 'sold', partner: @partner2)
      Fabricate(:consignment, state: 'bought in', partner: @partner2)
      Fabricate(:consignment, state: 'open', partner: @partner3)
      Fabricate(:consignment, state: 'sold', partner: @partner3)
    end

    describe 'grouped_by_state_and_partner' do
      subject { DashboardReportingQuery::Consignment.grouped_by_state_and_partner }

      it { is_expected.to include({
                                    open: { total: 3, artsy_curated: 2, auction_house: 1 },
                                    canceled: {total: 1, artsy_curated: 1, auction_house: 0},
                                    sold: {total: 3, artsy_curated: 2, auction_house: 1},
                                    "bought in": {total: 1, artsy_curated: 0, auction_house: 1}
        })
      }
    end
  end
end
