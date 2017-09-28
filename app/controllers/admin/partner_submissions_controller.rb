module Admin
  class PartnerSubmissionsController < ApplicationController
    before_action :set_pagination_params, only: [:digest]

    def digest
      @partner = Partner.find(params[:partner_id])
      partner_details_response = Gravql::Schema.execute(
        query: GravqlQueries::PARTNER_DETAILS_QUERY,
        variables: { ids: @partner.gravity_partner_id }
      )
      flash.now[:error] = 'Error fetching partner details.' if partner_details_response[:errors].present?
      @partner_details = partner_details_response[:data][:partners].first
      @partner_submissions = @partner.partner_submissions.where(notified_at: nil).page(@page).per(@size)
    end
  end
end
