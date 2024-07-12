# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ArtsyAuth::Authenticated
  helper Watt::Engine.helpers

  before_action :set_current_user
  before_action :set_raven_context
  before_action :set_paper_trail_whodunnit

  NotAuthorized = Class.new(StandardError)

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception

  expose(:page) { (params[:page] || 1).to_i }

  expose(:size) { (params[:size] || 100).to_i }

  # override application to decode token and allow only users with `admin` role
  def authorized_artsy_token?(token)
    ArtsyAdminAuth.valid?(token)
  end

  def set_current_user
    @current_user = ArtsyAdminAuth.decode_user(session[:access_token])
  end

  def set_raven_context
    Raven.user_context(id: @current_user)
  end

  def user_for_paper_trail
    @current_user
  end
end
