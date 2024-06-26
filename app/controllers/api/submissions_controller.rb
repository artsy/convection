# frozen_string_literal: true

module Api
  class SubmissionsController < RestController
    before_action :require_authentication, except: %i[create update]
    before_action :require_app_or_auth, only: %i[create update]
    before_action :set_submission, only: %i[show update]
    before_action :require_authorized_submission, only: %i[show update]

    def show
      render json: @submission.to_json, status: :ok
    end

    def create
      param! :artist_id, String, required: true
      submission =
        SubmissionService.create_submission(submission_params, current_user)
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

      if params.include? :state
        submissions = submissions.where(state: params[:state])
      end

      if params.include? :completed
        submissions =
          params[:completed] ? submissions.completed : submissions.draft
      end

      submissions = submissions.order(created_at: :desc).page(page).per(size)
      render json: submissions.to_json, status: :ok
    end

    private

    def require_app_or_auth
      if params[:gravity_user_id]
        require_trusted_app
        @current_user = User.anonymous.gravity_user_id
      else
        require_authentication
      end
    end

    def submission_params
      params
        .permit(
          :additional_info,
          :artist_id,
          :authenticity_certificate,
          :category,
          :currency,
          :deadline_to_sell,
          :depth,
          :dimensions_metric,
          :edition,
          :edition_number,
          :edition_size,
          :edition_size_formatted,
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
        .merge(user_agent: request.user_agent)
    end
  end
end
