module Admin
  class PartnersController < ApplicationController
    include GraphqlHelper

    before_action :set_pagination_params, only: [:index]

    def index
      @size = (params[:size] || 100).to_i
      @partners = Partner.order(id: :asc).page(@page).per(@size)
      @partner_details = partners_query(@partners.pluck(:gravity_partner_id))
    end
  end
end
