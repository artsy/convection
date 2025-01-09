# frozen_string_literal: true

module Admin
  class AssetsController < ApplicationController
    before_action :set_submission
    before_action :set_asset, only: %i[show destroy]
    before_action :authorize_submission, only: %i[new create destroy]

    def authorized_artsy_token?(token)
      # Allow access on edit/destructive actions to consignment reps (default: read-only).
      ArtsyAdminAuth.valid?(token, [ArtsyAdminAuth::CONSIGNMENTS_REPRESENTATIVE])
    end

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

      (params[:gemini_tokens] || []).each do |_, token|
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

    private

    def set_submission
      @submission = Submission.find(params[:submission_id])
    end

    def authorize_submission
      if !ArtsyAdminAuth.consignments_manager?(session[:access_token]) && @submission.assigned_to != @current_user
        raise ApplicationController::NotAuthorized
      end
    end

    def set_asset
      @asset = @submission.assets.find(params[:id])
    end
  end
end
