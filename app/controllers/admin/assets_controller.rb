# frozen_string_literal: true

module Admin
  class AssetsController < ApplicationController
    before_action :set_submission
    before_action :set_asset, only: %i[show destroy download]

    def show
      @original_image = @asset.original_image
    rescue Asset::GeminiHttpException
      @original_image = nil
      flash.now[:error] = "Error fetching Gemini image"
    end

    def new
      @asset = Asset.new
    end

    def multiple
      return if !params[:gemini_tokens] && !params[:additional_file_keys]

      (params[:gemini_tokens] || []).each do |token|
        @submission.assets.create(
          asset_type: params[:asset_type],
          gemini_token: token
        )
      end

      (params[:additional_file_keys] || []).each do |index, value|
        @submission.assets.create(
          filename: params[:additional_file_names][index],
          asset_type: params[:asset_type],
          s3_bucket: Convection.config[:aws_upload_bucket],
          s3_path: value
        )
      end

      redirect_to admin_submission_path(@submission)
    end

    def destroy
      @asset.destroy

      redirect_to admin_submission_path(@submission)
    end

    def download
      downloader = AssetDownloader.new(@asset)
      send_data downloader.data, filename: asset.filename, disposition: "attachment"
    rescue Aws::S3::Errors::NoSuchKey
      head :not_found
    rescue Aws::S3::Errors::AccessDenied
      head :unauthorized
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
