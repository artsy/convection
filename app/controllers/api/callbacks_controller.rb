module Api
  class CallbacksController < BaseController
    before_action :require_token

    def gemini
      param! :access_token, String, required: true
      param! :image_url, Hash, required: true
      param! :metadata, Hash, required: true
      param! :token, String, required: true

      submission = Submission.find(gemini_params[:metadata][:submission_id])
      asset = submission.assets.detect { |a| a.gemini_token == gemini_params[:token] }

      raise ActiveRecord::RecordNotFound unless asset && asset.gemini_token == gemini_params[:token]
      asset.update_image_urls!(gemini_params)
      render json: asset.to_json, status: 200
    end

    private

    def gemini_params
      params.permit(
        :access_token,
        :token,
        image_url: [:square],
        metadata: [:submission_id]
      )
    end

    def require_token
      raise ApplicationController::NotAuthorized unless params[:access_token] == Convection.config.access_token
    end
  end
end
