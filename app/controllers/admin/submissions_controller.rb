module Admin
  class SubmissionsController < ApplicationController
    before_action :set_submission, only: [:show, :edit, :update]
    before_action :set_user, only: [:show]
    before_action :set_artist, only: [:show]
    before_action :set_pagination_params, only: [:index]

    def index
      @submissions = Submission.order(id: :desc).page(@page).per(@size)
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

    private

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def set_user
      user = Gravity.client.user(id: @submission.user_id)._get
      @user_name = user.name
      @user_email = user.user_detail.email
    rescue Faraday::ResourceNotFound
      @user_name = @user_email = nil
    end

    def set_artist
      @artist = Gravity.client.artist(id: @submission.artist_id) if @submission.artist_id
    rescue Faraday::ResourceNotFound
      @artist = nil
    end

    def set_pagination_params
      @page = (params[:page] || 1).to_i
      @size = (params[:size] || 10).to_i
    end

    def submission_params
      params.require(:submission).permit(
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
        :width,
        :year
      )
    end
  end
end
