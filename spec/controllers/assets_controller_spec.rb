require 'rails_helper'
require 'support/gravity_helper'

describe Admin::AssetsController, type: :controller do
  context 'with a submission' do
    before do
      allow_any_instance_of(Admin::AssetsController).to receive(:require_artsy_authentication)
      stub_gravity_root
      stub_gravity_user
      stub_gravity_user_detail
      stub_gravity_artist
      @submission = Submission.create!(artist_id: 'artistid', user_id: 'userid')
    end

    context 'creating assets for a submission' do
      it 'correctly adds the assets for a single token' do
        expect do
          post :multiple, params: {
            gemini_tokens: 'token1',
            submission_id: @submission.id,
            asset_type: 'image'
          }
        end.to change(@submission.assets, :count).by(1)
      end

      it 'correctly adds the assets for multiple tokens' do
        expect do
          post :multiple, params: {
            gemini_tokens: 'token1 token2 token3 token4',
            submission_id: @submission.id,
            asset_type: 'image'
          }
        end.to change(@submission.assets, :count).by(4)
      end

      it 'creates no assets for a single token' do
        expect do
          post :multiple, params: { gemini_tokens: '', submission_id: @submission.id, asset_type: 'image' }
        end.to_not change(@submission.assets, :count)
      end
    end
  end
end
