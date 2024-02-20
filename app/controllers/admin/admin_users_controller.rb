# frozen_string_literal: true

module Admin
  class AdminUsersController < ApplicationController
    include ApplicationHelper

    before_action :authorize_user!
    before_action :set_admin_user, only: %i[show edit update destroy]

    # GET /admin/admin_users
    def index
      @admin_users = AdminUser.order("LOWER(name)").all
    end

    # GET /admin/admin_users/1
    def show
      redirect_to edit_admin_admin_user_path(params[:id])
    end

    # GET /admin/admin_users/new
    def new
      @admin_user = AdminUser.new
    end

    # GET /admin/admin_users/1/edit
    def edit; end

    # POST /admin/admin_users
    def create
      @admin_user = AdminUser.new(admin_user_params)
      load_admin_email

      if @admin_user.save
        redirect_to admin_admin_users_path,
                    notice: "Admin was successfully created."
      else
        render :new
      end
    end

    # PATCH/PUT /admin/admin_users/1
    def update
      if @admin_user.update(admin_user_params)
        redirect_to admin_admin_users_path,
                    notice: "Admin was successfully updated."
      else
        render :edit
      end
    end

    # DELETE /admin/admin_users/1
    def destroy
      @admin_user.destroy
      redirect_to admin_admin_users_url,
                  notice: "Admin was successfully destroyed."
    end

    private

    def set_admin_user
      @admin_user = AdminUser.find(params[:id])
    end

    def admin_user_params
      params
        .require(:admin_user)
        .permit(:name, :gravity_user_id, :super_admin, :assignee, :cataloguer)
    end

    def authorize_user!
      return if super_admin_user? @current_user

      raise ApplicationController::NotAuthorized
    end

    def load_admin_email
      begin
        user =
          Gravity.client.user(id: @admin_user.gravity_user_id).user_detail._get

        @admin_user.email = user.email if user
      rescue Faraday::ResourceNotFound
        nil
      end
    end
  end
end
