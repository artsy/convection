# frozen_string_literal: true

require 'rails_helper'

describe 'admin/partner_submissions/digest.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      @partner =
        Fabricate(:partner, gravity_partner_id: 'partnerid', name: 'Wright')

      gravql_artists_response = {
        data: { artists: [{ id: 'artist1', name: 'Andy Warhol' }] }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .with do |request|
        parsed = JSON.parse(request.body)
        parsed['variables']['ids'] == [] &&
          parsed['query'].include?('artistsDetails')
      end.to_return(body: gravql_artists_response.to_json)

      page.visit "/admin/partners/#{@partner.id}/submissions?notified_at="
    end

    it 'displays the page title and content' do
      expect(page).to have_content(
        'Submissions for Wright included in next digest'
      )
      expect(page).not_to have_selector('.list-item--submission')
    end

    describe 'with partner_submissions' do
      before do
        @submission =
          Fabricate(:submission, state: 'approved', artist_id: 'artistid')
        @already_notified_submission =
          Fabricate(:submission, state: 'approved', artist_id: 'artistid')

        Fabricate(
          :partner_submission,
          partner: @partner, submission: @submission
        )
        Fabricate(
          :partner_submission,
          partner: @partner,
          submission: @already_notified_submission,
          notified_at: Time.now.utc
        )

        gravql_artists_response = {
          data: { artists: [{ id: 'artist1', name: 'Andy Warhol' }] }
        }
        stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
          .with do |request|
          parsed = JSON.parse(request.body)
          parsed['variables']['ids'] == %w[artistid] &&
            parsed['query'].include?('artistsDetails')
        end.to_return(body: gravql_artists_response.to_json)
      end

      it 'displays partner_submissions with no notified_at' do
        page.visit "/admin/partners/#{@partner.id}/submissions?notified_at="
        expect(page).to have_content(
          'Submissions for Wright included in next digest'
        )
        expect(page).to have_selector('.list-item--submission', count: 1)
        expect(page).to have_content(@submission.id)
      end

      it 'displays all partner_submissions if notified_at is not passed in' do
        page.visit "/admin/partners/#{@partner.id}/submissions"
        expect(page).to have_content(
          'Submissions for Wright included in next digest'
        )
        expect(page).to have_selector('.list-item--submission', count: 2)
        expect(page).to have_content(@submission.id)
        expect(page).to have_content(@already_notified_submission.id)
      end
    end
  end
end
