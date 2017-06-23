module Admin
  class AssetsController < ApplicationController
    before_action :set_submission
    before_action :set_asset, only: :show

    def index
      @assets = @submission.assets.order(id: :desc).limit(10)
    end

    def show
      @original_image = @asset.original_image
    end

    def new
      @asset = Asset.new
    end

    def multiple
      if params[:gemini_tokens]
        gemini_tokens = params[:gemini_tokens].split(' ')
        gemini_tokens.each do |token|
          @submission.assets.create(asset_type: params[:asset_type], gemini_token: token)
        end
        redirect_to admin_submission_path(@submission)
      else
        return 'Please upload a file.'
      end
    end

    private

    def set_submission
      @submission = Submission.find(params[:submission_id])
    end

    def set_asset
      @asset = Asset.find(params[:id])
    end
  end
end
