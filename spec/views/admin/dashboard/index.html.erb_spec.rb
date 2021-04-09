# frozen_string_literal: true

require 'rails_helper'
require 'support/gravql_helper'
require 'support/gravity_helper'

describe 'admin/dashboard/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )

      stub_gravql_artists(body: {
        data: { artists: [{ id: 'artist1', name: 'Andy Warhol', is_p1: true, target_supply: true }] }
      })

      page.visit '/'
    end

    it 'displays the section titles' do
      expect(page).to have_content('Unreviewed Submissions 0')
      expect(page).to have_content('Open Offers 0')
      expect(page).not_to have_selector('.list-group-item')
    end

    context 'with just submissions' do
      before do
        6.times { Fabricate(:submission, state: 'submitted') }
        page.visit '/'
      end

      it 'displays four submissions' do
        expect(page).to have_selector('.list-item--offer', count: 0)
        expect(page).to have_selector('.list-item--submission', count: 4)
        expect(page).to have_selector('.list-item--consignment', count: 0)
        expect(page).to have_content('Unreviewed Submissions 6')
        expect(page).to have_content('Open Offers 0')
        expect(page).to have_content('Active Consignments 0')
      end

      it 'lets you click a submission' do
        submission = Submission.submitted.order(id: :desc).first
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)
        stub_gravity_artist(id: submission.artist_id)

        find(".list-item--submission[data-id='#{submission.id}']").click
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content('State submitted')
      end
    end

    context 'with some offers and submissions and consignments' do
      before do
        5.times { Fabricate(:offer, state: 'sent') }
        6.times { Fabricate(:submission, state: 'submitted') }
        Fabricate(:submission, state: 'draft')
        Fabricate(:offer, state: 'draft')
        5.times { Fabricate(:consignment, state: 'open') }
        page.visit '/'
      end

      it 'displays four of each type' do
        expect(page).to have_selector('.list-item--offer', count: 4)
        expect(page).to have_selector('.list-item--submission', count: 4)
        expect(page).to have_selector('.list-item--consignment', count: 4)
        expect(page).to have_content('Unreviewed Submissions 6')
        expect(page).to have_content('Open Offers 5')
        expect(page).to have_content('Active Consignments 5')
      end

      it 'lets you click an offer' do
        offer = Offer.sent.order(id: :desc).first
        stub_gravity_root
        stub_gravity_user(id: offer.submission.user.gravity_user_id)
        stub_gravity_user_detail(id: offer.submission.user.gravity_user_id)
        stub_gravity_artist(id: offer.submission.artist_id)

        find(".list-item--offer[data-id='#{offer.id}']").click
        expect(page).to have_content("Offer ##{offer.reference_id}")
        expect(page).to have_content('State sent')
        expect(page).to have_content('Offer Lapsed')
      end

      it 'lets you click a submission' do
        submission = Submission.submitted.order(id: :desc).first
        stub_gravity_root
        stub_gravity_user(id: submission.user.gravity_user_id)
        stub_gravity_user_detail(id: submission.user.gravity_user_id)
        stub_gravity_artist(id: submission.artist_id)

        find(".list-item--submission[data-id='#{submission.id}']").click
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content('State submitted')
      end

      it 'lets you click a consignment' do
        consignment = PartnerSubmission.consigned.order(id: :desc).first
        stub_gravity_root
        stub_gravity_user(id: consignment.submission.user.gravity_user_id)
        stub_gravity_user_detail(
          id: consignment.submission.user.gravity_user_id
        )
        stub_gravity_artist(id: consignment.submission.artist_id)

        find(".list-item--consignment[data-id='#{consignment.id}']").click
        expect(page).to have_content("Consignment ##{consignment.reference_id}")
        expect(page).to have_content('State open')
      end

      it 'lets you view all consignments' do
        within(:css, '.active-consignments') { click_link('See All') }

        expect(page.current_path).to eq admin_consignments_path
      end
    end
  end
end
