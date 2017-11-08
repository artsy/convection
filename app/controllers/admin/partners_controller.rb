module Admin
  class PartnersController < ApplicationController
    expose(:partners) do
      partners = Partner.all
      partners = partners.search_by_name(params[:term]) if params[:term]
      partners = partners.order(name: :asc).page(@page).per(@size)
      partners
    end

    expose(:term) do
      params[:term]
    end

    include GraphqlHelper
    before_action :set_pagination_params, only: [:index]

    def index; end
  end
end
