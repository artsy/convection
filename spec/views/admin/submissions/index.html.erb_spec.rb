# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/submissions/index.html.erb', type: :feature do
  context 'always' do
    before do
      stub_gravity_root
      stub_gravity_artist(id: 'artistid2')
      stub_gravity_user(id: 'userid2')
      stub_gravity_user_detail(id: 'userid2')

      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      gravql_artists_response = {
        data: { artists: [{ id: 'artist1', name: 'Andy Warhol' }] }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_artists_response.to_json)
        .with(
        headers: {
          'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
        }
      )
      page.visit admin_submissions_path
    end

    it 'displays the page title' do
      expect(page).to have_content('Submissions')
      expect(page).to have_selector('.list-group-item', count: 1)
    end

    it 'shows the submission states that can be selected' do
      within(:css, '#submission-filter-form') do
        expect(page).to have_content('all')
        expect(page).to have_content('submitted')
        expect(page).to have_content('draft')
        expect(page).to have_content('approved')
        expect(page).to have_content('rejected')
      end
    end

    context 'with submissions' do
      before do
        user = Fabricate(:user, gravity_user_id: 'userid')
        3.times do
          Fabricate(
            :submission,
            user: user, artist_id: 'artistid', state: 'submitted'
          )
        end
        page.visit admin_submissions_path
      end

      it 'displays all of the submissions' do
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 4)
      end

      it 'lets you click a submission' do
        stub_gravity_user
        stub_gravity_user_detail
        stub_gravity_artist

        submission = Submission.order(id: :desc).first
        find(".list-item--submission[data-id='#{submission.id}']").click
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content('Edit')
        expect(page).to have_content('Assets')
        expect(page).to have_content('Jon Jonson')
      end

      it 'lets you click a filter option', js: true do
        select('submitted', from: 'state')
        expect(current_url).to include '&state=submitted'
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 4)
        expect(current_path).to eq admin_submissions_path
      end
    end

    context 'with a variety of submissions' do
      before do
        @user1 =
          Fabricate(
            :user,
            gravity_user_id: 'userid', email: 'jon-jonson@test.com'
          )
        @user2 =
          Fabricate(:user, gravity_user_id: 'userid2', email: 'percy@test.com')
        3.times do
          Fabricate(
            :submission,
            user: @user1,
            artist_id: 'artistid',
            state: 'submitted',
            title: 'blah'
          )
        end
        @submission =
          Fabricate(
            :submission,
            user: @user2,
            artist_id: 'artistid2',
            state: 'approved',
            title: 'my work'
          )
        Fabricate(
          :submission,
          user: @user2,
          artist_id: 'artistid4',
          state: 'rejected',
          title: 'title'
        )
        Fabricate(
          :submission,
          user: @user2,
          artist_id: 'artistid4',
          state: 'draft',
          title: 'blah blah'
        )

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
            'X-XAPP-TOKEN' => 'xapp_token', 'Content-Type' => 'application/json'
          }
        )
        page.visit admin_submissions_path
      end

      it 'shows the correct artist names' do
        expect(page).to have_content('Andy Warhol', count: 3)
        expect(page).to have_content('Kara Walker', count: 1)
        expect(page).to_not have_content('Chuck Close')
        expect(page).to have_content('Lucille Bluth', count: 2)
      end

      it 'lets you click into a filter option', js: true do
        select('approved', from: 'state')
        expect(current_url).to include '&state=approved'
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'filters by changing the url' do
        page.visit('/admin/submissions?state=rejected')
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 2)
      end

      it 'allows you to search by user and state', js: true do
        select('draft', from: 'state')
        fill_in('term', with: 'percy')
        expect(page).to have_selector('.ui-autocomplete')
        click_link("user-#{@user2.id}")
        expect(current_url).to include "state=draft&user=#{@user2.id}"
        expect(page).to have_selector('.list-group-item', count: 2)
        expect(page).to have_content('draft', count: 2)
      end

      it 'allows you to navigate to a specific submission', js: true do
        fill_in('term', with: @submission.id)
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_selector('.ui-menu-item')
        click_link("submission-#{@submission.id}")
        expect(current_path).to eq admin_submission_path(@submission)
      end

      it 'allows you to search by user email', js: true do
        fill_in('term', with: 'percy')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('User   percy')
        click_link("user-#{@user2.id}")
        expect(current_url).to include "&user=#{@user2.id}"
        expect(page).to have_selector('.list-group-item', count: 4)
        expect(page).to have_content 'my work'
        expect(page).to have_content 'blah blah'
      end

      it 'allows you to search by user email, filter by state, and sort by ID',
         js: true do
        select('approved', from: 'state')
        fill_in('term', with: 'percy')
        expect(page).to have_selector('.ui-autocomplete')
        expect(page).to have_content('User   percy')
        click_link("user-#{@user2.id}")
        expect(current_url).to include("user=#{@user2.id}", 'state=approved')
        click_link('ID')
        expect(current_url).to include(
          "user=#{@user2.id}",
          'state=approved',
          'sort=id',
          'direction=desc'
        )
      end
    end
  end
end
