module Admin
  class SubmissionsController < ApplicationController
    include GraphqlHelper

    before_action :set_submission, only: [:show, :edit, :update]

    expose(:submissions) do
      matching_submissions = Submission.all
      matching_submissions = matching_submissions.search(params[:term]) if params[:term].present?
      matching_submissions = matching_submissions.where(state: params[:state]) if params[:state].present?
      matching_submissions = matching_submissions.where(user_id: params[:user]) if params[:user].present?

      sort = params[:sort].presence || 'id'
      direction = params[:direction].presence || 'asc'

      matching_submissions = if sort.include?('users')
                               matching_submissions.includes(:user).reorder("#{sort} #{direction}")
                             else
                               matching_submissions.reorder("#{sort} #{direction}")
                             end
      matching_submissions.page(page).per(size)
    end

    expose(:artist_details) do
      artists_query(submissions.map(&:artist_id))
    end

    expose(:filters) do
      { state: params[:state], user: params[:user], sort: params[:sort], direction: params[:direction] }
    end

    def index
      respond_to do |format|
        format.html
        format.json do
          submissions_with_thumbnails = submissions.map { |submission| submission.as_json.merge(thumbnail: submission.thumbnail) }
          render json: submissions_with_thumbnails || []
        end
      end
    end

    def new
      @submission = Submission.new
    end

    def create
      @submission = SubmissionService.create_submission(submission_params.merge(state: 'submitted'), params[:submission][:user_id])
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError => e
      @submission = Submission.new(submission_params)
      flash.now[:error] = e.message
      render 'new'
    end

    def show
      notified_partner_submissions = @submission.partner_submissions.where.not(notified_at: nil)
      @partner_submissions_count = notified_partner_submissions.group_by_day.count
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
        term = params[:term]
        artists = Gravity.client.artists(term: term).artists
      end
      respond_to do |format|
        format.json { render json: artists || [] }
      end
    end

    def match_user
      if params[:term]
        term = params[:term]
        users = Gravity.client.users(term: term).users
      end
      respond_to do |format|
        format.json { render json: users || [] }
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
        :width,
        :year
      )
    end
  end
end
