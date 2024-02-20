# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"
require "support/gravql_helper"

describe "admin/submissions/new.html.erb", type: :feature do
  context "always" do
    before do
      allow_any_instance_of(Admin::SubmissionsController).to receive(
        :require_artsy_authentication
      )
      page.visit "/admin/submissions/new"
    end

    it "displays the page title and content" do
      expect(page).to have_content("New Submission")
      expect(page).to have_content("Painting")
    end

    it "lets you update the submission title and redirects back to the show page" do
      add_default_stubs

      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        "xapp_token"
      )
      stub_gravql_artists(
        body: {
          data: {
            artists: [{id: "artist1", name: "Gob Bluth"}]
          }
        }
      )

      fill_in("submission_title", with: "my new artwork title")
      find("#submission_artist_id").set("artistid")
      find("#submission_user_id").set("userid")
      find_button("Create").click
      expect(page).to have_content("Submission #")
      expect(page).to have_content("my new artwork title")
      expect(page).to have_content("Gob Bluth".upcase)
    end
  end
end
