module Admin
  class UsersController < ApplicationController
    before_action :set_pagination_params, only: :index

    expose(:users) do
      matching_users = User.all
      matching_users = matching_users.search(params[:term]) if params[:term].present?
      matching_users.page(@page).per(@size)
    end

    expose(:term) do
      params[:term]
    end

    def index
      respond_to do |format|
        format.json { render json: users || [] }
      end
    end
  end
end
