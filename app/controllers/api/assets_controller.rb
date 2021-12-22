# frozen_string_literal: true

module Api
  class AssetsController < RestController
    before_action :require_authentication
    before_action :set_submission_and_asset, only: %i[show]
    before_action :set_submission, only: %i[create index]
    before_action :require_authorized_submission

    def index
      param! :submission_id, String, required: true

      assets = @submission.assets.limit(10)
      render json: assets.to_json, status: :ok
    end

    def show
      param! :id, String, required: true

      render json: @asset.to_json, status: :ok
    end

    def create
      param! :asset_type, String, default: 'image'
      param! :gemini_token, String, required: true
      param! :submission_id, String, required: true

      asset = @submission.assets.create!(asset_params)
      SubmissionService.notify_user(@submission.id) if @submission.submitted?
      render json: asset.to_json, status: :created
    end

    private

    def set_submission_and_asset
      @asset = Asset.find(params[:id])
      @submission = @asset.submission
    end

    def asset_params
      params.permit(:asset_type, :gemini_token, :submission_id)
    end
  end
end
