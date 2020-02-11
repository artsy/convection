require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/submissions/new.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(
        :require_artsy_authentication
      )
      page.visit '/admin/submissions/new'
    end

    it 'displays the page title and content' do
      expect(page).to have_content('New Submission')
      expect(page).to have_content('Painting')
    end

    it 'lets you update the submission title and redirects back to the show page' do
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail
      stub_gravity_artist

      fill_in('submission_title', with: 'my new artwork title')
      find('#submission_artist_id').set('artistid')
      find('#submission_user_id').set('userid')
      find_button('Create').click
      expect(page).to have_content('Submission #')
      expect(page).to have_content('my new artwork title')
      expect(page).to have_content('Gob Bluth'.upcase)
      expect(page).to have_content('Jon Jonson')
    end
  end
end
