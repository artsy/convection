# frozen_string_literal: true

module Admin
  class PartnerSubmissionsController < ApplicationController
    include GraphqlHelper

    def index
      @filters = { notified_at: params[:notified_at] }
      notified_at = params[:notified_at].presence

      @partner = Partner.find(params[:partner_id])

      partner_submissions = @partner.partner_submissions
      if params[:notified_at]
        partner_submissions =
          partner_submissions.where(notified_at: notified_at)
      end
      @partner_submissions = partner_submissions.page(page).per(size)
      @artist_details =
        artists_query(@partner_submissions.map(&:submission).map(&:artist_id))
    end
  end
end
