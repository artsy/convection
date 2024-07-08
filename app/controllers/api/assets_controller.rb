# frozen_string_literal: true

module Api
  class AssetsController < RestController
    before_action :require_authentication
    before_action :set_submission_and_asset, only: %i[show download]
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
      param! :asset_type, String, default: "image"
      param! :gemini_token, String, required: true
      param! :submission_id, String, required: true

      asset = @submission.assets.create!(asset_params)
      SubmissionService.notify_user(@submission.id) if @submission.submitted?
      render json: asset.to_json, status: :created
    end

    def download
      param! :id, String, required: true

      return unless @asset.asset_type == "additional_file"

      user = User.find_by(gravity_user_id: current_user)
      return head :unauthorized unless user.can?(:download, @asset)

      downloader = AssetDownloader.new(@asset)
      send_data downloader.data, filename: @asset.filename, disposition: "attachment"
    rescue Aws::S3::Errors::NoSuchKey
      head :not_found
    rescue Aws::S3::Errors::AccessDenied
      head :unauthorized
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
