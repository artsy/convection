# frozen_string_literal: true

module Admin
  class AssetsController < ApplicationController
    before_action :set_submission
    before_action :set_asset, only: %i[show destroy]

    def show
      @original_image = @asset.original_image
    rescue Asset::GeminiHttpException
      @original_image = nil
      flash.now[:error] = 'Error fetching Gemini image'
    end

    def new
      @asset = Asset.new
    end

    def multiple
      return unless params[:gemini_tokens]

      gemini_tokens = params[:gemini_tokens].split
      gemini_tokens.each do |token|
        @submission.assets.create(
          asset_type: params[:asset_type],
          gemini_token: token
        )
      end
      redirect_to admin_submission_path(@submission)
    end

    def destroy
      @asset.destroy

      redirect_to admin_submission_path(@submission)
    end

    private

    def set_submission
      @submission = Submission.find(params[:submission_id])
    end

    def set_asset
      @asset = @submission.assets.find(params[:id])
    end
  end
end
