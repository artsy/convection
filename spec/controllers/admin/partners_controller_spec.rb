# frozen_string_literal: true

require "rails_helper"

describe Admin::PartnersController, type: :controller do
  describe "with some partners" do
    let!(:partner1) { Fabricate(:partner, name: "zz top") }
    let!(:partner2) { Fabricate(:partner, name: "abracadabra") }
    let!(:partner3) { Fabricate(:partner, name: "animal prints") }
    let!(:partner4) { Fabricate(:partner, name: "bubbles") }
    let!(:partner5) { Fabricate(:partner, name: "gagosian") }

    before do
      allow_any_instance_of(Admin::PartnersController).to receive(
        :require_artsy_authentication
      )
    end

    describe "#index" do
      context "with successful partner details request" do
        it "returns the first two partners on the first page" do
          get :index, params: {page: 1, size: 2}
          expect(controller.partners.count).to eq 2
        end
        it "paginates correctly" do
          get :index, params: {page: 3, size: 2}
          expect(controller.partners.count).to eq 1
        end
        it "orders the partners correctly" do
          get :index, params: {page: 1}
          expect(controller.partners.count).to eq 5
          expect(controller.partners.map(&:name)).to eq(
            ["abracadabra", "animal prints", "bubbles", "gagosian", "zz top"]
          )
        end
      end
    end

    describe "#create" do
      it "does nothing if there is no gravity_partner_id" do
        expect { post :create, params: {} }.to_not change(Partner, :count)
      end

      it "redirects to the index view on success" do
        expect {
          post :create,
               params: {
                 gravity_partner_id: "123",
                 name: "New Gallery"
               }
          expect(Partner.reorder(id: :desc).first.name).to eq "New Gallery"
          expect(response).to redirect_to(:admin_partners)
        }.to change(Partner, :count).by(1)
      end

      it "renders the index view with an error on failure" do
        allow_any_instance_of(Partner).to receive(:save).and_return(false)
        expect {
          post :create,
               params: {
                 gravity_partner_id: "123",
                 name: "New Gallery"
               }
          expect(controller.flash[:error]).to include(
            "Error creating gravity partner."
          )
          expect(response).to render_template(:index)
        }.to_not change(Partner, :count)
      end

      it "does not allow you to create a partner with a duplicate gravity_partner_id" do
        expect {
          post :create,
               params: {
                 gravity_partner_id: partner1.gravity_partner_id,
                 name: "New Gallery"
               }
          expect(controller.flash[:error]).to eq(
            "Error creating gravity partner. Gravity partner has already been taken"
          )
          expect(response).to render_template(:index)
        }.to_not change(Partner, :count)
      end
    end
  end
end
