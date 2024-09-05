require "rails_helper"
require "support/graphql_helper"
require "support/gravity_helper"
require "support/gravql_helper"
require "support/jwt_helper"

describe "Listing a new artwork", type: :feature do
  let(:submission) { Fabricate(:submission, state: "approved", title: "My Artwork") }
  let(:admin_id) { "adminid" }

  before do
    add_default_stubs(
      id: submission.user.gravity_user_id,
      artist_id: submission.artist_id
    )

    # Skip roles check
    allow_any_instance_of(ApplicationController).to receive(
      :require_artsy_authentication
    )
    allow_any_instance_of(Admin::SubmissionsController).to receive(
      :authorize_submission
    )

    # Set current user
    stub_jwt_header(admin_id)

    allow(Convection.config).to receive(:gravity_xapp_token).and_return("xapp_token")
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
    stub_graphql_artwork_request(submission.my_collection_artwork_id)
  end

  it "lists artwork" do
    visit admin_submission_path(submission)
    expect(page).to have_content("My Artwork")
    expect(page).to have_content("approved")

    click_on "List Artwork"
    expect(page).to have_content("Please select a partner")

    stub_gravity_request("/v1/artist/#{submission.artist_id}", {public: true})
    stub_gravity_request("/v1/artwork", {_id: "abc123"}, :post)

    find_field(id: "gravity_partner_id", type: :hidden).set("foo")
    click_on "Create Artwork"
    expect(page).to have_content("Created artwork")
    expect(page).to have_content("Listed Artworks")
    expect(page).to have_content("abc123")
    expect(submission.reload.listed_artwork_ids).to include("abc123")
  end
end
