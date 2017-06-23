require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/submissions/index.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(:require_artsy_authentication)
      page.visit '/'
    end

    it 'displays the page title' do
      expect(page).to have_content('Submissions')
      expect(page).not_to have_selector('list-group-item')
    end

    context 'with submissions' do
      before do
        3.times do |index|
          Submission.create!(title: "Artwork #{index}", user_id: 'userid', artist_id: 'artistid')
        end
        page.visit '/'
      end

      it 'displays all of the submissions' do
        expect(page).to have_content('Submissions')
        expect(page).to have_selector('.list-group-item', count: 3)
      end

      it 'lets you click a submission' do
        stub_gravity_root
        stub_gravity_user
        stub_gravity_user_detail
        stub_gravity_artist

        submission = Submission.order(id: :desc).first
        click_link("Submission #{submission.id}")
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content('Edit Submission')
        expect(page).to have_content('Add Asset')
        expect(page).to have_content('Jon Jonson')
      end
    end
  end
end
