module Admin
  class PartnersController < ApplicationController
    include GraphqlHelper
    before_action :set_pagination_params, only: [:index]

    def index
      @partners = Partner.order(name: :asc).page(@page).per(@size)
    end
  end
end
