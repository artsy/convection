# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

RSpec.describe "/admin/admin_users", type: :request do
  before do
    allow_any_instance_of(ArtsyAuth::Authenticated).to receive(
      :require_artsy_authentication
    ).and_return(true)

    allow_any_instance_of(Admin::AdminUsersController).to receive(
      :authorize_user!
    ).and_return(true)

    stub_gravity_root
    stub_gravity_user(id: "userid")
    stub_gravity_user_detail(id: "userid")
  end

  let!(:admin_user) { Fabricate(:admin_user, name: "paul") }

  describe "GET /index" do
    it "renders a successful response" do
      get admin_admin_users_url

      expect(response).to be_successful
      expect(response.body).to include("paul")
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_admin_admin_user_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_admin_admin_user_url(admin_user)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new AdminUser" do
        expect {
          post admin_admin_users_url,
            params: {
              admin_user: {
                name: "paula",
                gravity_user_id: "userid"
              }
            }
        }.to change(AdminUser, :count).by(1)

        expect(response).to redirect_to(admin_admin_users_url)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested admin_user" do
        patch admin_admin_user_url(admin_user),
          params: {
            admin_user: {
              name: "paula"
            }
          }
        expect(admin_user.reload.name).to eq("paula")
        expect(response).to redirect_to(admin_admin_users_url)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested admin_user" do
      expect { delete admin_admin_user_url(admin_user) }.to change(
        AdminUser,
        :count
      ).by(-1)
      expect(response).to redirect_to(admin_admin_users_url)
    end
  end
end
