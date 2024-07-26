# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"
require "support/gravql_helper"

describe "admin/submissions/index.html.erb", type: :feature do
  context "always" do
    before do
      add_default_stubs(id: "userid2", artist_id: "artistid2")

      stub_gravity_artwork(id: "artworkid2")
      stub_gravity_artworks

      allow_any_instance_of(ApplicationController).to receive(
        :require_artsy_authentication
      )
      allow(Convection.config).to receive(:gravity_xapp_token).and_return(
        "xapp_token"
      )

      stub_gravql_artists(
        body: {
          data: {
            artists: [{id: "artist1", name: "Andy Warhol"}]
          }
        }
      )

      page.visit admin_submissions_path
    end

    it "displays the page title" do
      expect(page).to have_content("Submissions")
      expect(page).to have_selector(".list-group-item", count: 1)
    end

    it "shows the submission states that can be selected" do
      within(:css, "#submission-filter-form") do
        expect(page).to have_content("all")
        expect(page).to have_content("submitted")
        expect(page).to have_content("resubmitted")
        expect(page).to have_content("draft")
        expect(page).to have_content("approved")
        expect(page).to have_content("rejected")
      end
    end

    context "with submissions" do
      before do
        user = Fabricate(:user, gravity_user_id: "userid")
        stub_gravity_user(id: "userid")
        stub_gravity_user_detail(id: "userid")
        3.times do
          Fabricate(
            :submission,
            user: user,
            artist_id: "artistid",
            state: "submitted"
          )
        end
        page.visit admin_submissions_path
      end

      it "displays all of the submissions" do
        expect(page).to have_content("Submissions")
        expect(page).to have_selector(".list-group-item", count: 4)
      end

      it "lets you click a submission" do
        stub_gravity_artist

        submission = Submission.order(id: :desc).first
        find(".list-item--submission[data-id='#{submission.id}']").click
        expect(page).to have_content("Submission ##{submission.id}")
        expect(page).to have_content("Edit")
        expect(page).to have_content("Assets")
        expect(page).to have_content("Jon Jonson")
      end

      it "lets you click a filter option", js: true do
        select("submitted", from: "state")
        expect(current_url).to include "state=submitted"
        expect(page).to have_content("Submissions")
        expect(page).to have_selector(".list-group-item", count: 4)
        expect(current_path).to eq admin_submissions_path
      end
    end

    context "with a variety of submissions" do
      before do
        @user1 =
          Fabricate(
            :user,
            gravity_user_id: "userid",
            email: "jon-jonson@test.com"
          )
        @user2 =
          Fabricate(:user, gravity_user_id: "userid2", email: "percy@test.com")
        stub_gravity_user(id: "userid", email: "jon-jonson@test.com")
        stub_gravity_user_detail(id: "userid", email: "jon-jonson@test.com")
        stub_gravity_user(id: "userid2", email: "percy@test.com")
        stub_gravity_user_detail(id: "userid2", email: "percy@test.com")
        3.times do
          Fabricate(
            :submission,
            user: @user1,
            artist_id: "artistid",
            state: "submitted",
            title: "blah"
          )
        end
        @submission =
          Fabricate(
            :submission,
            user: @user2,
            artist_id: "artistid2",
            state: "approved",
            title: "my work"
          )
        Fabricate(
          :submission,
          user: @user2,
          artist_id: "artistid4",
          state: "rejected",
          title: "title"
        )
        Fabricate(
          :submission,
          user: @user2,
          artist_id: "artistid4",
          state: "draft",
          title: "blah blah"
        )

        @artists = [
          {id: "artistid", name: "Andy Warhol"},
          {id: "artistid2", name: "Kara Walker"},
          {id: "artistid3", name: "Chuck Close"},
          {id: "artistid4", name: "Lucille Bluth"}
        ]

        stub_gravql_artists(body: {data: {artists: @artists}})

        page.visit admin_submissions_path
      end

      it "shows the correct artist names" do
        expect(page).to have_content("Andy Warhol", count: 3)
        expect(page).to have_content("Kara Walker", count: 1)
        expect(page).to_not have_content("Chuck Close")
        expect(page).to have_content("Lucille Bluth", count: 2)
      end

      it "lets you click into a filter option", js: true do
        select("approved", from: "state")
        expect(current_url).to include "state=approved"
        expect(page).to have_content("Submissions")
        expect(page).to have_selector(".list-group-item", count: 2)
      end

      it "filters by changing the url" do
        page.visit("/admin/submissions?state=rejected")
        expect(page).to have_content("Submissions")
        expect(page).to have_selector(".list-group-item", count: 2)
      end

      it "allows you to search by user and state", js: true do
        select("draft", from: "state")
        page.all(:fillable_field, "term").last.set("percy")
        expect(page).to have_selector(".ui-autocomplete")
        click_link("user-#{@user2.id}")
        expect(current_url).to include "state=draft&user=#{@user2.id}"
        expect(page).to have_selector("input[value='#{@user2.email}']")
        expect(page).to have_selector(".list-group-item", count: 2)
        expect(page).to have_content("draft", count: 2)
      end

      it "allows you to navigate to a specific submission", js: true do
        page.all(:fillable_field, "term").last.set(@submission.id)
        expect(page).to have_selector(".ui-autocomplete")
        expect(page).to have_selector(".ui-menu-item")
        click_link("submission-#{@submission.id}")
        expect(current_path).to eq admin_submission_path(@submission)
      end

      it "allows you to search by user email", js: true do
        page.all(:fillable_field, "term").last.set("percy")
        expect(page).to have_selector(".ui-autocomplete")
        expect(page).to have_content("User   percy")
        click_link("user-#{@user2.id}")
        expect(current_url).to include "&user=#{@user2.id}"
        expect(page).to have_selector("input[value='#{@user2.email}']")
        expect(page).to have_selector(".list-group-item", count: 4)
        expect(page).to have_content "my work"
        expect(page).to have_content "blah blah"
      end

      it "allows you to search by artist name", js: true do
        artist = @artists.last

        stub_gravity_artists(override_body: [artist])

        stub_gravql_artists(body: {data: {artists: [artist]}})

        page.all(:fillable_field, "term").last.set(artist[:name])
        expect(page).to have_selector(".ui-autocomplete")
        expect(page).to have_content(artist[:name])
        click_link("artist-#{artist[:id]}")
        expect(current_url).to include "&artist=#{artist[:id]}"
        expect(page).to have_selector("input[value='#{artist[:name]}']")
        expect(page).to have_selector(".list-group-item-info--artist", count: 2)
        expect(page).to have_content "title"
        expect(page).to have_content "blah blah"
      end

      it "allows you to search by artist name and state", js: true do
        artist = @artists.last

        stub_gravity_artists(override_body: [artist])

        stub_gravql_artists(body: {data: {artists: [artist]}})

        page.all(:fillable_field, "term").last.set(artist[:name])
        expect(page).to have_selector(".ui-autocomplete")
        expect(page).to have_content(artist[:name])
        click_link("artist-#{artist[:id]}")
        select("draft", from: "state")
        expect(current_url).to include("artist=#{artist[:id]}", "state=draft")
        expect(page).to have_selector("input[value='#{artist[:name]}']")
        expect(page).to have_selector(".list-group-item-info--artist", count: 1)
        expect(page).to have_content "blah blah"
        select("approved", from: "state")
        expect(page).to have_selector(".list-group-item-info--artist", count: 0)
      end

      it "allows you to search by user email, filter by state, and sort by ID",
        js: true do
        select("approved", from: "state")
        page.all(:fillable_field, "term").last.set("percy")
        expect(page).to have_selector(".ui-autocomplete")
        expect(page).to have_content("User   percy")
        click_link("user-#{@user2.id}")
        expect(current_url).to include("user=#{@user2.id}", "state=approved")
        click_link("ID")
        expect(current_url).to include(
          "user=#{@user2.id}",
          "state=approved",
          "sort=id",
          "direction=desc"
        )
      end
    end
  end
end
