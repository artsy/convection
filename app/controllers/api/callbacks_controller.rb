# frozen_string_literal: true

module Api
  class CallbacksController < RestController
    before_action :require_token

    def gemini
      param! :access_token, String, required: true
      param! :image_url, Hash, required: true
      param! :metadata, Hash, required: true
      param! :token, String, required: true

      submission = Submission.find(gemini_params[:metadata][:id])
      asset =
        submission.assets.detect { |a| a.gemini_token == gemini_params[:token] }

      unless asset && asset.gemini_token == gemini_params[:token]
        raise ActiveRecord::RecordNotFound
      end

      asset.update_image_urls!(gemini_params)
      render json: asset.reload.to_json, status: :ok
    end

    private

    def gemini_params
      params.permit(
        :access_token,
        :token,
        image_url: %i[square large medium thumbnail],
        metadata: %i[id _type]
      )
    end

    def require_token
      unless params[:access_token] == Convection.config.access_token
        raise ApplicationController::NotAuthorized
      end
    end
  end
end
