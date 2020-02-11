# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    expose(:users) do
      matching_users = User.all
      if params[:term].present?
        matching_users = matching_users.search(params[:term])
      end
      matching_users.page(page).per(size)
    end

    expose(:term) { params[:term] }

    def index
      respond_to { |format| format.json { render json: users || [] } }
    end
  end
end
