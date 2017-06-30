require 'rails_helper'
require 'support/gravity_helper'

describe 'admin/submissions/show.html.erb', type: :feature do
  context 'always' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:require_artsy_authentication)
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail
      stub_gravity_artist

      @submission = Fabricate(:submission,
        title: 'my sartwork',
        artist_id: 'artistid',
        edition: true,
        edition_size: 100,
        edition_number: '23a',
        category: 'Painting',
        user_id: 'userid')
      page.visit "/admin/submissions/#{@submission.id}"
    end

    it 'displays the page title and content' do
      expect(page).to have_content("Submission ##{@submission.id}")
      expect(page).to have_content('Gob Bluth')
      expect(page).to have_content('Jon Jonson')
      expect(page).to have_content('user@example.com')
      expect(page).to have_content('Painting')
    end

    context 'with assets' do
      before do
        4.times do
          Fabricate(:image, submission: @submission, gemini_token: nil)
        end
        page.visit "/admin/submissions/#{@submission.id}"
      end

      it 'displays all of the assets' do
        expect(page).to have_content('Assets count')
        expect(page).to have_selector('.list-group-item', count: 4)
      end

      it 'lets you click an asset' do
        asset = @submission.assets.first
        click_link("image ##{asset.id}")
        expect(page).to have_content("Asset ##{asset.id}")
        expect(page).to have_content("Submission ##{@submission.id}")
        expect(page).to_not have_content('View Original')
      end
    end
  end
end
