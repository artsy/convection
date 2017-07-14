module Admin
  class SubmissionsController < ApplicationController
    before_action :set_submission, only: [:show, :edit, :update]
    before_action :set_user, only: [:show]
    before_action :set_pagination_params, only: [:index]

    def index
      @submissions = Submission.order(id: :desc).page(@page).per(@size)
    end

    def new
      @submission = Submission.new
    end

    def create
      @submission = Submission.new(submission_params)
      if @submission.save
        redirect_to admin_submission_path(@submission)
      else
        render 'new'
      end
    end

    def show; end

    def edit; end

    def update
      if @submission.update_attributes!(submission_params)
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

    def set_user
      @user_name = @submission.user_name
      @user_email = @submission.user_detail.try(:email)
    end

    def set_artist_name
      @artist_name = @submission.artist_name if @submission.artist_id
    end

    def set_pagination_params
      @page = (params[:page] || 1).to_i
      @size = (params[:size] || 10).to_i
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
