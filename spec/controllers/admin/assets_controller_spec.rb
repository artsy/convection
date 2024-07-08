# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe Admin::AssetsController, type: :controller do
  context "with a submission" do
    before do
      allow_any_instance_of(Admin::AssetsController).to receive(
        :require_artsy_authentication
      )
      add_default_stubs
      @submission =
        Fabricate(
          :submission,
          artist_id: "artistid",
          user: Fabricate(:user, gravity_user_id: "userid")
        )
    end

    context "fetching an asset" do
      it "renders the show page if the asset exists" do
        asset = Fabricate(:image, submission: @submission, gemini_token: nil)
        get :show, params: {submission_id: @submission.id, id: asset.id}
        expect(response).to render_template(:show)
      end

      it "returns a 404 if the asset does not exist" do
        expect {
          get :show, params: {submission_id: @submission.id, id: "foo"}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "renders a flash error if the original image cannot be found" do
        asset = Fabricate(:image, submission: @submission)
        expect_any_instance_of(Asset).to receive(:original_image).and_raise(
          Asset::GeminiHttpException
        )
        get :show, params: {submission_id: @submission.id, id: asset.id}
        expect(response).to render_template(:show)
        expect(assigns(:asset)["original_image"]).to be_nil
      end
    end

    context "removing an asset on a submission" do
      it "removes an existing asset" do
        asset = Fabricate(:image, submission: @submission)

        expect {
          delete :destroy,
            params: {
              submission_id: @submission.id,
              id: asset.id
            }
        }.to change(@submission.assets, :count).by(-1)
      end
    end

    context "creating assets for a submission" do
      it "correctly adds the assets for a single token" do
        expect {
          post :multiple,
            params: {
              "gemini_tokens[]" => "token1",
              :submission_id => @submission.id,
              :asset_type => "image"
            }
        }.to change(@submission.assets, :count).by(1)
      end

      it "correctly adds the assets for multiple tokens" do
        expect {
          post :multiple,
            params: {
              "gemini_tokens[0]" => "token1",
              "gemini_tokens[1]" => "token2",
              "gemini_tokens[2]" => "token3",
              "gemini_tokens[3]" => "token4",
              :submission_id => @submission.id,
              :asset_type => "image"
            }
        }.to change(@submission.assets, :count).by(4)
      end
    end
  end
end
