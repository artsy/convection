module Api
  class AssetsController < BaseController
    before_action :require_authorized_user
    before_action :require_authorized_submission

    def show
      asset = Asset.find(params[:id])
      render json: asset.to_json, status: 200
    end

    def create
      param! :submission_id, String, required: true
      param! :gemini_token, String, required: true

      submission = Submission.find(params[:submission_id])
      asset = submission.assets.create(asset_params)
      render json: asset.to_json, status: 201
    end

    private

    def asset_params
      params.permit(
        :asset_type,
        :gemini_token,
        :submission_id
      )
    end
  end
end
