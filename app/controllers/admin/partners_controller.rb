module Admin
  class PartnersController < ApplicationController
    expose(:partners) do
      matching_partners = Partner.all
      matching_partners = matching_partners.search_by_name(params[:term]) if params[:term]
      matching_partners.page(@page).per(@size)
    end

    expose(:term) do
      params[:term]
    end

    include GraphqlHelper
    before_action :set_pagination_params, only: [:index]

    def index; end
  end
end
