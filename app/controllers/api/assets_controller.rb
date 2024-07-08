# frozen_string_literal: true

module Api
  class AssetsController < RestController
    before_action :require_authentication
    before_action :set_submission_and_asset, only: %i[show, download]
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
      param! :id

      return unless @asset.asset_type == "additional_file"

      user = User.find_by(gravity_user_id: current_user)
      return head :unauthorized unless user.can?(:download, @asset)

      aws_client = Aws::S3::Client.new(region: 'us-east-1', access_key_id: Convection.config[:aws_access_key_id], secret_access_key: Convection.config[:aws_secret_access_key])
      object = aws_client.get_object(bucket: asset.s3_bucket, key: asset.s3_path)
      send_data object.body.read, filename: File.basename(asset.filename), disposition: 'attachment'
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
