# frozen_string_literal: true

module Admin
  class SubmissionsController < ApplicationController
    include GraphqlHelper

    before_action :set_submission,
                  only: %i[
                    show
                    edit
                    update
                    undo_approval
                    undo_publish
                    undo_rejection
                    undo_close
                  ]

    expose(:submissions) do
      matching_submissions = SubmissionMatch.find_all(params)
      matching_submissions.page(page).per(size)
    end

    expose(:artist_details) { artists_query(submissions.map(&:artist_id)) }

    expose(:filters) do
      {
        assigned_to: params[:assigned_to],
        state: params[:state],
        user: params[:user],
        sort: params[:sort],
        direction: params[:direction]
      }
    end

    def index
      respond_to do |format|
        format.html
        format.json do
          submissions_with_thumbnails =
            submissions.map do |submission|
              submission.as_json.merge(thumbnail: submission.thumbnail)
            end
          render json: submissions_with_thumbnails || []
        end
      end
    end

    def new
      @submission = Submission.new
    end

    def create
      @submission =
        SubmissionService.create_submission(
          submission_params.merge(state: 'submitted'),
          submission_params[:user_id]
        )
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError => e
      @submission = Submission.new(submission_params)
      flash.now[:error] = e.message
      render 'new'
    end

    def show
      notified_partner_submissions =
        @submission.partner_submissions.where.not(notified_at: nil)
      @partner_submissions_count =
        notified_partner_submissions.group_by_day.count
      @offers = @submission.offers
      @notes = @submission.notes
      @actions = SubmissionStateActions.for(@submission)
    end

    def edit; end

    def update
      result =
        SubmissionService.update_submission(
          @submission,
          submission_params,
          current_user: @current_user
        )

      if result
        redirect_to admin_submission_path(@submission)
      else
        render 'edit'
      end
    end

    def undo_approval
      SubmissionService.undo_approval(@submission)
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError => e
      flash[:error] = e.message
      redirect_to admin_submission_path(@submission)
    end

    def undo_publish
      SubmissionService.undo_publish(@submission)
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError => e
      flash[:error] = e.message
      redirect_to admin_submission_path(@submission)
    end

    def undo_rejection
      SubmissionService.undo_rejection(@submission)
      redirect_to admin_submission_path(@submission)
    end

    def undo_close
      SubmissionService.undo_close(@submission)
      redirect_to admin_submission_path(@submission)
    end

    def match_artist
      if params[:term]
        term = params[:term]
        artists = Gravity.client.artists(term: term).artists
      end
      respond_to { |format| format.json { render json: artists || [] } }
    end

    def match_user
      if params[:term]
        term = params[:term]
        users = Gravity.client.users(term: term).users
      end
      respond_to { |format| format.json { render json: users || [] } }
    end

    private

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      safelist = %i[
        artist_id
        authenticity_certificate
        category
        currency
        deleted_at
        depth
        dimensions_metric
        edition_number
        edition_size
        height
        location_city
        location_country
        location_state
        medium
        minimum_price_dollars
        primary_image_id
        provenance
        signature
        state
        title
        user_id
        width
        year
      ]

      permitted_params = params.require(:submission).permit(safelist)
      permitted_params[:assigned_to] =
        params.dig(:submission, :assigned_to).presence
      permitted_params
    end
  end
end
