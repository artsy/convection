# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'
require 'support/gravql_helper'

describe 'admin/submissions/edit.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(
        :require_artsy_authentication
      )
      @submission =
        Fabricate(
          :submission,
          title: 'my artwork',
          artist_id: 'artistid',
          edition: true,
          edition_size: 100,
          edition_number: '23a',
          category: 'Painting',
          user: Fabricate(:user, gravity_user_id: 'userid')
        )
      add_default_stubs

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        'xapp_token'
      )
      stub_gravql_artists(
        body: {
          data: {
            artists: [
              {
                id: @submission.artist_id,
                name: 'Gob Bluth',
                is_p1: false,
                target_supply: true
              }
            ]
          }
        }
      )

      page.visit "/admin/submissions/#{@submission.id}/edit"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Submission ##{@submission.id}")
      expect(page.find('#submission_title').value).to eq('my artwork')
      expect(page).to_not have_content('Gob Bluth')
      expect(page).to_not have_content('P2')
      expect(page).to_not have_content('Jon Jonson')
      expect(page).to_not have_content('user@example.com')
      expect(page).to have_content('Painting')
    end

    it 'lets you update the submission title and redirects back to the show page' do
      fill_in('submission_title', with: 'my new artwork title')
      find_button('Save').click
      expect(@submission.reload.title).to eq('my new artwork title')
      expect(page).to have_content('Gob Bluth'.upcase)
      expect(page).to have_content('P2')
      expect(page).to have_content('Add New')
    end

    it 'lets you update the submission and not affect the assigned user' do
      expect(@submission.assigned_to).to eq nil
      fill_in('submission_title', with: 'my new artwork title')
      find_button('Save').click
      @submission.reload
      expect(@submission.title).to eq('my new artwork title')
      expect(@submission.assigned_to).to eq nil
    end
  end
end
