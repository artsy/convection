module Api
  class SubmissionsController < BaseController
    before_action :require_authentication
    before_action :set_submission, only: [:show, :update]
    before_action :require_authorized_submission, only: [:show, :update]

    def show
      render json: @submission.to_json, status: 200
    end

    def create
      param! :artist_id, String, required: true

      create_params = submission_params(params).merge(user_id: current_user)
      submission = SubmissionService.create_submission(create_params)
      render json: submission.to_json, status: 201
    end

    def update
      @submission.update_attributes(submission_params(params))
      render json: @submission.to_json, status: 201
    end

    private

    def submission_params(params)
      params.permit(
        :artist_id,
        :title,
        :medium,
        :year,
        :category,
        :height,
        :width,
        :depth,
        :dimensions_metric,
        :signature,
        :authenticity_certificate,
        :provenance,
        :location_city,
        :location_state,
        :location_country,
        :deadline_to_sell,
        :additional_info
      )
    end
  end
end
