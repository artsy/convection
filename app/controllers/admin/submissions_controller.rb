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
        list_artwork
      ]
    before_action :set_submission_artist, only: %i[show edit]

    expose(:submissions) do
      matching_submissions = SubmissionMatch.find_all(params)
      matching_submissions.page(page).per(size)
    end

    before_action :build_listing_fields, only: %i[show list_artwork]

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
        user_email: params[:user_email],
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
          submission_params.merge(state: "submitted"),
          submission_params[:user_id],
          current_user: @current_user
        )
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError => e
      @submission = Submission.new(submission_params)
      flash.now[:error] = e.message
      render "new"
    end

    def show
      notified_partner_submissions =
        @submission.partner_submissions.where.not(notified_at: nil)
      @partner_submissions_count =
        notified_partner_submissions.group_by_day.count
      @offers = @submission.offers
      @notes = @submission.notes + @submission.user&.notes.to_a
      @actions = SubmissionStateActions.for(@submission)
      @partner_name = @submission.consigned_partner_submission&.partner&.name
    end

    def edit
    end

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
        render "edit"
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

    def list_artwork
      artwork_params = {
        partner: params[:gravity_partner_id],
        import_source: "convection",
        external_id: @submission.id
      }.with_indifferent_access

      params[:artwork_sources].each do |key, value|
        if value == "submission"
          artwork_params[key] = @submission_artwork_params[key.to_sym]
        elsif value == "salesforce"
          artwork_params[key] = @salesforce_artwork_params[key.to_sym]
        end
      end

      edition_set_params = {}.with_indifferent_access
      if @submission.edition?
        params[:edition_set_sources].each do |key, value|
          if value == "submission"
            edition_set_params[key] = @submission_edition_set_params[key.to_sym]
          elsif value == "salesforce"
            edition_set_params[key] = @salesforce_edition_set_params[key.to_sym]
          end
        end
      end

      images_or_urls = []
      Array(params[:image_ids]).each do |image_id|
        images_or_urls << @submission.images.find(image_id)
      end
      Array(params[:salesforce_image_urls]).each do |image_url|
        images_or_urls << image_url
      end

      artwork = SubmissionService.list_artwork(@submission, session[:access_token], artwork_params, edition_set_params, images_or_urls)

      flash[:success] = "Created artwork #{artwork["_id"]}"
      redirect_to admin_submission_path(@submission)
    rescue SubmissionService::SubmissionError, GravityV1::GravityError => e
      flash[:error] = e.message
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

    def match_user_by_contact_info
      if params[:term]
        term = params[:term]

        # Exclude anonymous submissions from the submissions with a matching email
        submissions =
          Submission
            .where("user_email like ?", "%#{term}%")
            .where
            .not(user_id: nil)
            .limit(1)
        if submissions.empty?
          users = []
        else
          user = {
            id: submissions.first.user_id,
            email: submissions.first.user_email
          }
          users = [user]
        end
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
        edition_size_formatted
        exhibition
        height
        location_city
        location_country
        location_state
        location_postal_code
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
        source_artwork_id
      ]

      permitted_params = params.require(:submission).permit(safelist)
      if params[:submission][
        :assigned_to
      ].present?
        permitted_params[:assigned_to] =
          params.dig(:submission, :assigned_to)
      end
      permitted_params
    end

    def build_listing_fields
      @submission_artwork_params = @submission.to_artwork_params || {}
      @salesforce_artwork_params = (SalesforceService.salesforce_artwork_to_artwork_params(@submission.salesforce_artwork) || {}).compact
      @artwork_fields = @submission_artwork_params.keys | @salesforce_artwork_params.keys

      @submission_edition_set_params = (@submission.to_edition_set_params || {}).compact
      @salesforce_edition_set_params = (SalesforceService.salesforce_artwork_to_edition_set_params(@submission.salesforce_artwork) || {}).compact
      @edition_set_fields = @submission_edition_set_params.keys | @salesforce_edition_set_params.keys

      @artwork_sources = Hash.new("submission")
      @edition_set_sources = Hash.new("submission")
    end
  end
end
