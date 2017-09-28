require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/partner_submissions/digest.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
      allow(Convection.config).to receive(:gravity_xapp_token).and_return('xapp_token')
      @partner = Fabricate(:partner, gravity_partner_id: 'partnerid')
      gravql_partners_response = {
        data: {
          partners: [
            { id: 'partner1', given_name: 'Wright' }
          ]
        }
      }
      stub_request(:post, "#{Convection.config.gravity_api_url}/graphql")
        .to_return(body: gravql_partners_response.to_json)
        .with(
          headers: {
            'X-XAPP-TOKEN' => 'xapp_token',
            'Content-Type' => 'application/json'
          }
        )
      page.visit "/admin/partners/#{@partner.id}/submissions/digest"
    end

    it 'displays the page title and content' do
      expect(page).to have_content('Submissions for Wright included in next digest')
      expect(page).not_to have_selector('.list-item--submission')
    end

    it 'displays partner_submissions with no notified_at' do
      submission = Fabricate(:submission, state: 'approved', artist_id: 'artistid')
      already_notified_submission = Fabricate(:submission, state: 'approved')

      Fabricate(:partner_submission, partner: @partner, submission: submission)
      Fabricate(:partner_submission, partner: @partner, submission: already_notified_submission, notified_at: Time.now.utc)

      stub_gravity_root
      stub_gravity_artist

      page.visit "/admin/partners/#{@partner.id}/submissions/digest"
      expect(page).to have_content('Submissions for Wright included in next digest')
      expect(page).to have_selector('.list-item--submission', count: 1)
      expect(page).to have_content(submission.id)
    end
  end
end
