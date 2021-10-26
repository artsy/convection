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
    before_action :set_submission_artist, only: %i[show edit]

    expose(:submissions) do
      matching_submissions = SubmissionMatch.find_all(params)
      matching_submissions.page(page).per(size)
    end

    expose(:artist_details) do
      artists_names_query(submissions.map(&:artist_id))
    end

    expose(:display_term) do
      if filters[:user].present?
        User.where(id: filters[:user]).pick(:email)
      elsif filters[:artist].present?
        artists_names_query([filters[:artist]])&.values&.first
      end
    end
    expose(:filters) do
      {
        assigned_to: params[:assigned_to],
        state: params[:state],
        cataloguer: params[:cataloguer],
        category: params[:category],
        user: params[:user],
        artist: params[:artist],
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
      params[:edition_size] = params.delete(:edition_size_temp) if params[
        :edition_size_temp
      ].presence
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
      @notes = @submission.notes + @submission.user.notes
      @actions = SubmissionStateActions.for(@submission)
      @partner_name = @submission.consigned_partner_submission&.partner&.name
    end

    def edit; end

    def update
      params[:edition_size] = params.delete(:edition_size_temp) if params[
        :edition_size_temp
      ].presence
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

    def match_artwork
      if params[:term]
        term = params[:term]
        artworks = Gravity.client.artworks(term: term).artworks
      end
      respond_to { |format| format.json { render json: artworks || [] } }
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

    def set_submission_artist
      @artist = artists_details_query([@submission.artist_id]).first
    end

    def submission_params
      safelist = %i[
        artist_id
        attribution_class
        authenticity_certificate
        artist_proofs
        additional_info
        category
        currency
        condition_report
        deleted_at
        depth
        cataloguer
        rejection_reason
        dimensions_metric
        edition_number
        edition_size
        edition_size_temp
        exhibition
        height
        location_city
        location_country
        location_state
        literature
        medium
        minimum_price_dollars
        primary_image_id
        provenance
        publisher
        signature
        signature_detail
        state
        title
        user_id
        width
        year
      ]

      permitted_params = params.require(:submission).permit(safelist)
      permitted_params[:assigned_to] =
        params.dig(:submission, :assigned_to) if params[:submission][
        :assigned_to
      ].present?
      permitted_params
    end
  end
end
