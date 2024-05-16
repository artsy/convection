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
      if Convection.unleash.enabled?(
        "onyx-mp-backed-artwork-details",
        Unleash::Context.new(user_id: @current_user) # current_user is a User#gravity_user_id for some reason
      )
        set_artwork_details!
      end

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
      artwork = SubmissionService.list_artwork(@submission, params[:gravity_partner_id], session[:access_token])
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

    def set_artwork_details!
      return unless @submission.my_collection_artwork_id

      response = artwork_details_query(@submission.my_collection_artwork_id, session[:access_token])
      return unless response

      @artwork_details = OpenStruct.new(
        artist_name: response.try(:[], :artist).try(:[], :name),
        title: response.try(:[], :title),
        signature: response.try(:[], :signature),
        category: response.try(:[], :mediumType).try(:[], :name),
        medium: response.try(:[], :medium),
        edition_size: response.try(:[], :editionSize),
        edition_number: response.try(:[], :editionNumber),
        dimensions_in: response.try(:[], :dimensions).try(:[], :in),
        dimensions_cm: response.try(:[], :dimensions).try(:[], :cm),
        year: response.try(:[], :date),
        provenance: response.try(:[], :provenance),
        has_certificate_of_authenticity: response.try(:[], :hasCertificateOfAuthenticity) || "No",
        certificate_of_authenticity_details: response.try(:[], :certificateOfAuthenticity).try(:[], :details),
        coa_by_authenticating_body: "N/A", # Not yet supported
        coa_by_gallery: "N/A", # Not yet supported
        location: "N/A", # Not yet supported
        price_in_mind: response.try(:[], :pricePaid).try(:[], :display),
        is_p1: response.try(:[], :artist).try(:[], :targetSupply).try(:[], :isP1),
        target_supply: response.try(:[], :artist).try(:[], :targetSupply).try(:[], :isTargetSupply),
        images: response.try(:[], :images)&.map do |image|
          OpenStruct.new(url: image.try(:[], :resized).try(:[], :url), default: image.try(:[], :isDefault))
        end
      )
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
  end
end
