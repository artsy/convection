module Admin
  class PartnersController < ApplicationController
    before_action :set_pagination_params, only: [:index]

    def index
      @size = (params[:size] || 100).to_i
      @partners = Partner.order(id: :asc).page(@page).per(@size)
      partners_details_response = Gravql::Schema.execute(
        query: GravqlQueries::PARTNER_DETAILS_QUERY,
        variables: { ids: @partners.pluck(:gravity_partner_id) }
      )
      flash.now[:error] = 'Error fetching some partner details.' if partners_details_response[:errors].present?
      @partner_details = partners_details_response[:data][:partners].map { |pd| [pd[:id], pd] }.to_h
    end
  end
end
