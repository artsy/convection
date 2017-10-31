require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/submissions/index.html.erb', type: :feature do
  context 'always' do
    before do
      stub_gravity_root

      allow_any_instance_of(Admin::SubmissionsController).to receive(:require_artsy_authentication)
      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      gravql_artists_response = {
        data: {
          artists: [
            { id: 'artist1', name: 'Andy Warhol' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )
      page.visit '/'
    end

    it 'displays the page title' do
      expect(page).to have_content('Submissions')
      expect(page).not_to have_selector('.list-group-item')
    end

    it 'displays zeros for the counts' do
      expect(page).to have_content('All 0')
      expect(page).to have_content('Unreviewed 0')
      expect(page).to have_content('Approved 0')
      expect(page).to have_content('Rejected 0')
    end

    context 'with submissions' do
      before do
        3.times { Fabricate(:submission, user_id: 'userid', artist_id: 'artistid', state: 'submitted') }
        page.visit '/'
      end

      it 'displays all of the submissions' do
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 3)
      end

      it 'lets you click a submission' do
        stub_gravity_user
        stub_gravity_user_detail
        stub_gravity_artist

        submission = Submission.order(id: :desc).first
        within(:css, ".list-item--submission[data-id='#{submission.id}']") do
          click_link('View')
        end
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content('Edit')
        expect(page).to have_content('Add Asset')
        expect(page).to have_content('Jon Jonson')
      end

      it 'shows the counts of submissions' do
        expect(page).to have_content('All 3')
        expect(page).to have_content('Unreviewed 3')
        expect(page).to have_content('Approved 0')
        expect(page).to have_content('Rejected 0')
      end

      it 'lets you click a filter option' do
        click_link('Unreviewed')
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 3)
        expect(current_path).to eq '/admin/submissions'
      end
    end

    context 'with a variety of submissions' do
      before do
        3.times { Fabricate(:submission, user_id: 'userid', artist_id: 'artistid', state: 'submitted') }
        Fabricate(:submission, user_id: 'userid', artist_id: 'artistid2', state: 'approved')
        Fabricate(:submission, user_id: 'userid', artist_id: 'artistid4', state: 'rejected')
        Fabricate(:submission, user_id: 'userid', artist_id: 'artistid4', state: 'draft')

        gravql_artists_response = {
          data: {
            artists: [
              { id: 'artistid', name: 'Andy Warhol' },
              { id: 'artistid2', name: 'Kara Walker' },
              { id: 'artistid3', name: 'Chuck Close' },
              { id: 'artistid4', name: 'Lucille Bluth' }
            ]
          }
        }
        stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
          .to_return(body: gravql_artists_response.to_json)
          .with(
            headers: {
              'X-XAPP-TOKEN' => 'xapp_token',
              'Content-Type' => 'application/json'
            }
          )
        page.visit '/'
      end

      it 'shows the correct artist names' do
        expect(page).to have_content('Andy Warhol', count: 3)
        expect(page).to have_content('Kara Walker', count: 1)
        expect(page).to_not have_content('Chuck Close')
        expect(page).to have_content('Lucille Bluth', count: 1)
      end

      it 'shows the correct numbers' do
        expect(page).to have_content('All 5')
        expect(page).to have_content('Unreviewed 3')
        expect(page).to have_content('Approved 1')
        expect(page).to have_content('Rejected 1')
      end

      it 'lets you click into a filter option' do
        click_link('Approved')
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 1)
      end

      it 'filters by changing the url' do
        page.visit('/admin/submissions?state=rejected')
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 1)
      end
    end
  end
end
