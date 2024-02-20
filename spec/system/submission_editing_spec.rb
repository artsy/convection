# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"
require "support/gravql_helper"
require "support/jwt_helper"

describe "Editing a submission", type: :feature do
  let(:submission) do
    Fabricate(
      :submission,
      title: "my sartwork",
      artist_id: "artistid",
      edition: true,
      edition_size: 100,
      edition_number: "23a",
      category: "Painting",
      user: Fabricate(:user, gravity_user_id: "userid"),
      state: "submitted"
    )
  end
  let(:admin_id) { "adminid" }

  before do
    add_default_stubs(
      id: submission.user.gravity_user_id,
      artist_id: submission.artist_id
    )

    allow(Convection.config).to receive(:auction_offer_form_url).and_return(
      "https://google.com/auction"
    )

    # Skip roles check
    allow_any_instance_of(ApplicationController).to receive(
      :require_artsy_authentication
    )

    # Set current user
    stub_jwt_header(admin_id)

    # Stub gravity representation of current user
    stub_gravity_user(
      id: admin_id,
      email: "admin@art.sy",
      name: "Blake Adminmeier"
    )

    allow(Convection.config).to receive(:gravity_xapp_token).and_return(
      "xapp_token"
    )
    stub_gravql_artists(
      body: {
        data: {
          artists: [
            {
              id: submission.artist_id,
              name: "Gob Bluth",
              is_p1: false,
              target_supply: true
            }
          ]
        }
      }
    )
  end

  context "adding an admin to a submission" do
    context "from the edit screen" do
      it "displays that admin on the submission detail page" do
        visit admin_submission_path(submission)
        expect(page).to_not have_select(
          "submission[assigned_to]",
          selected: "Alice"
        )

        click_on "Edit", match: :first
        expect(page).to_not have_content "Assigned To:"

        click_button "Save"

        expect(page).to have_current_path(admin_submission_path(submission))
      end
    end

    context "from the detail screen" do
      before { Fabricate(:admin_user, name: "Agnieszka", assignee: true) }

      it "displays that admin on the submission detail page" do
        visit admin_submission_path(submission)
        expect(page).to_not have_select(
          "submission[assigned_to]",
          selected: "Alice"
        )

        select "Agnieszka", from: "submission[assigned_to]"
        click_button "Update", match: :first

        expect(page).to have_current_path(admin_submission_path(submission))
        expect(page).to have_select(
          "submission[assigned_to]",
          selected: "Agnieszka"
        )
      end
    end
  end

  context "creating a new note" do
    before { visit admin_submission_path(submission) }
    it "user can create a new note" do
      within(:css, ".notes-section") do
        fill_in("note[body]", with: "This is a really cool artwork. Wow!")
        click_button "Create"
      end

      within(:css, ".notes-section .list-group-item--body p") do
        expect(page).to have_content("This is a really cool artwork. Wow!")
      end
    end

    it "user sees an error if the note cannot be created" do
      within(:css, ".notes-section") { click_button "Create" }

      expect(page).to have_content("Could not create note: Body can't be blank")
    end
  end
end
