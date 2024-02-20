# frozen_string_literal: true

module Admin
  class PartnerSubmissionsController < ApplicationController
    include GraphqlHelper

    def index
      @filters = {notified_at: params[:notified_at]}
      notified_at = params[:notified_at].presence

      @partner = Partner.find(params[:partner_id])

      partner_submissions = @partner.partner_submissions
      if params[:notified_at]
        partner_submissions =
          partner_submissions.where(notified_at: notified_at)
      end
      @partner_submissions = partner_submissions.page(page).per(size)

      artists_ids =
        @partner_submissions.filter_map { |p_s| p_s.submission&.artist_id }
      @artist_details = artists_names_query(artists_ids)
    end
  end
end
