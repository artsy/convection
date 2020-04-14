# frozen_string_literal: true

class StateActions
  def self.for(submission)
    new(submission).run
  end

  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def run
    actions = []
    actions << approve_action if submission.submitted?
    actions << publish_action if submission.submitted? || submission.approved?
    actions << reject_action if submission.submitted?
    actions
  end

  private

  def default_classes
    ['btn btn-secondary btn-small btn-full-width']
  end

  def approve_action
    {
      class: default_classes << 'btn-approve',
      confirm:
        'An email will be sent to the consignor, letting them know that their submission will be sent to our partner network and this work will appear in the digests and CMS. This action cannot be undone.',
      state: 'approved',
      text: 'Approve (convection only)'
    }
  end

  def publish_action
    {
      class: default_classes << 'btn-approve',
      confirm:
        'An email will be sent to the consignor, letting them know that their submission will be sent to our partner network and this work will appear in the digests and CMS. This action cannot be undone.',
      state: 'published',
      text: 'Publish (CMS + digest)'
    }
  end

  def reject_action
    {
      class: default_classes << 'btn-delete',
      confirm:
        'An email will be sent to the consignor, letting them know that we are not accepting their submission. This action cannot be undone.',
      state: 'rejected',
      text: 'Reject'
    }
  end
end

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
                  ]

    expose(:submissions) do
      matching_submissions = Submission.not_deleted
      if params[:term].present?
        matching_submissions = matching_submissions.search(params[:term])
      end
      if params[:state].present?
        matching_submissions = matching_submissions.where(state: params[:state])
      end
      if params[:user].present?
        matching_submissions =
          matching_submissions.where(user_id: params[:user])
      end

      sort = params[:sort].presence || 'id'
      direction = params[:direction].presence || 'desc'

      matching_submissions =
        if sort.include?('users')
          matching_submissions.includes(:user).reorder(
            "#{sort} #{direction}, submissions.id desc"
          )
        else
          matching_submissions.reorder("#{sort} #{direction}")
        end
      matching_submissions.page(page).per(size)
    end

    expose(:artist_details) { artists_query(submissions.map(&:artist_id)) }

    expose(:filters) do
      {
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
          params[:submission][:user_id]
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
      @actions = StateActions.for(@submission)
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
      params.require(:submission).permit(
        :artist_id,
        :assigned_to,
        :authenticity_certificate,
        :category,
        :currency,
        :deleted_at,
        :depth,
        :dimensions_metric,
        :edition_number,
        :edition_size,
        :height,
        :location_city,
        :location_country,
        :location_state,
        :medium,
        :minimum_price_dollars,
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
