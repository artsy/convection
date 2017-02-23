module Api
  class SubmissionsController < BaseController
    def create
      param! :user_id, String, required: true
      param! :artist_id, String, required: true

      submission = SubmissionService.create_submission(submission_params(params))
      render json: submission.to_json, status: 201
    end

    private

    def submission_params(params)
      params.permit(
        :user_id,
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
