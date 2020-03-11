# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

describe 'Editing a submission' do
  context 'adding an admin to a submission' do
    it 'displays that admin on the submission detail page' do
      allow_any_instance_of(Admin::SubmissionsController).to receive(
        :require_artsy_authentication
      )

      submission = Fabricate :submission

      stub_gravity_root
      stub_gravity_user(id: submission.user.gravity_user_id)
      stub_gravity_user_detail(id: submission.user.gravity_user_id)
      stub_gravity_artist(id: submission.artist_id)

      visit admin_submission_path(submission)
      expect(page).to have_content('Unassigned')

      click_on 'Edit'
      expect(page).to have_content 'Assigned To:'

      select 'Alice', from: 'submission[assigned_to]'
      click_button 'Save'

      expect(page).to have_current_path(admin_submission_path(submission))
      expect(page).to have_content('Alice')
    end
  end
end
