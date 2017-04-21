module Api
  class SubmissionsController < BaseController
    skip_before_action :verify_authenticity_token
    skip_before_action :require_artsy_authentication
    before_action :require_authorized_user
    before_action :require_authorized_submission, only: [:show, :update]

    rescue_from ActiveRecord::RecordNotFound do |_e|
      error!('Submission Not Found', 404)
    end

    def show
      submission = Submission.find(params[:submission_id])
      render json: submission.to_json, status: 200
    end

    def create
      param! :artist_id, String, required: true

      create_params = submission_params(params).merge(user_id: current_user)
      submission = SubmissionService.create_submission(create_params)
      render json: submission.to_json, status: 201
    end

    def update
      submission = Submission.find(params[:submission_id])
      submission.update_attributes(submission_params(params))
      render json: submission.to_json, status: 201
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
