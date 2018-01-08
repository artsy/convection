module Admin
  class SubmissionsController < ApplicationController
    include GraphqlHelper

    before_action :set_submission, only: [:show, :edit, :update]
    before_action :set_pagination_params, only: [:index]

    def index
      @counts = Submission.group(:state).count
      @completed_submissions_count = Submission.completed.count
      @filters = { state: params[:state] }

      @submissions = params[:state] ? Submission.where(state: params[:state]) : Submission.completed
      @submissions = @submissions.search(params[:term]) if params[:term]
      @submissions = @submissions.order(id: :desc).page(@page).per(@size)
      @artist_details = artists_query(@submissions.map(&:artist_id))

      respond_to do |format|
        format.html
        format.json do
          submissions_with_thumbnails = @submissions.map { |submission| submission.as_json.merge(thumbnail: submission.thumbnail) }
          render json: submissions_with_thumbnails || []
        end
      end
    end

    def new
      @submission = Submission.new
    end

    def create
      @submission = Submission.new(submission_params.merge(state: 'submitted'))
      if @submission.save
        redirect_to admin_submission_path(@submission)
      else
        render 'new'
      end
    end

    def show
      notified_partner_submissions = @submission.partner_submissions.where.not(notified_at: nil)
      @partner_submissions_count = notified_partner_submissions.group_by_day.count

      @consignment = @submission.consigned_partner_submission

      @offers = @submission.offers
    end

    def edit; end

    def update
      if SubmissionService.update_submission(@submission, submission_params, @current_user)
        redirect_to admin_submission_path(@submission)
      else
        render 'edit'
      end
    end

    def match_artist
      if params[:term]
        @term = params[:term]
        @artists = Gravity.client.artists(term: @term).artists
      end
      respond_to do |format|
        format.json { render json: @artists || [] }
      end
    end

    def match_user
      if params[:term]
        @term = params[:term]
        @users = Gravity.client.users(term: @term).users
      end
      respond_to do |format|
        format.json { render json: @users || [] }
      end
    end

    private

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(
        :artist_id,
        :authenticity_certificate,
        :category,
        :depth,
        :dimensions_metric,
        :edition_number,
        :edition_size,
        :height,
        :location_city,
        :location_country,
        :location_state,
        :medium,
        :primary_image_id,
        :provenance,
        :signature,
        :state,
        :title,
        :user_id,
        :width,
        :year
      )
    end
  end
end
