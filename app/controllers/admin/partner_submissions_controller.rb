module Admin
  class PartnerSubmissionsController < ApplicationController
    include GraphqlHelper

    before_action :set_pagination_params, only: [:index]

    def index
      @filters = { notified_at: params[:notified_at] }
      notified_at = params[:notified_at] && params[:notified_at].blank? ? nil : params[:notified_at]

      @partner = Partner.find(params[:partner_id])
      @partner_details = partners_query(@partner.gravity_partner_id)

      partner_submissions = @partner.partner_submissions
      partner_submissions = partner_submissions.where(notified_at: notified_at) if params[:notified_at]
      @partner_submissions = partner_submissions.page(@page).per(@size)
      @artist_details = artists_query(@partner_submissions.map(&:submission).map(&:artist_id))
    end
  end
end
