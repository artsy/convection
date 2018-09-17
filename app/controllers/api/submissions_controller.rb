module Api
  class SubmissionsController < BaseController
    before_action :require_authentication
    before_action :set_submission, only: [:show, :update]
    before_action :require_authorized_submission, only: [:show, :update]

    def show
      render json: @submission.to_json, status: :ok
    end

    def create
      param! :artist_id, String, required: true
      submission = SubmissionService.create_submission(submission_params, current_user)
      render json: submission.to_json, status: :created
    end

    def update
      SubmissionService.update_submission(@submission, submission_params)
      render json: @submission.to_json, status: :created
    end

    def index
      param! :completed, :boolean, default: nil

      user = User.where(gravity_user_id: current_user).first
      submissions = Submission.where(user: user)
      if params.include? :completed
        submissions = params[:completed] ? submissions.completed : submissions.draft
      end

      submissions = submissions.order(created_at: :desc).page(page).per(size)
      render json: submissions.to_json, status: :ok
    end

    private

    def submission_params
      params.permit(
        :additional_info,
        :artist_id,
        :authenticity_certificate,
        :category,
        :deadline_to_sell,
        :depth,
        :dimensions_metric,
        :edition,
        :edition_number,
        :edition_size,
        :height,
        :location_city,
        :location_country,
        :location_state,
        :medium,
        :minimum_price_dollars,
        :provenance,
        :signature,
        :state,
        :title,
        :width,
        :year
      )
    end
  end
end
