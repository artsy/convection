module Admin
  class PartnerSubmissionsController < ApplicationController
    before_action :set_pagination_params, only: [:index]

    def index
      @partner = Partner.find(params[:partner_id])
      partner_details_response = Gravql::Schema.execute(
        query: GravqlQueries::PARTNER_DETAILS_QUERY,
        variables: { ids: @partner.gravity_partner_id }
      )
      flash.now[:error] = 'Error fetching partner details.' if partner_details_response[:errors].present?
      @partner_details = partner_details_response[:data][:partners].first
      @filters = { notified_at: params[:notified_at] }
      notified_at = params[:notified_at] && params[:notified_at].blank? ? nil : params[:notified_at]

      partner_submissions = @partner.partner_submissions
      partner_submissions = partner_submissions.where(notified_at: notified_at) if params[:notified_at]
      @partner_submissions = partner_submissions.page(@page).per(@size)
    end
  end
end
