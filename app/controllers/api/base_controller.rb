module Api
  class BaseController < ApplicationController
    include AuthenticationHelpers

    skip_before_action :verify_authenticity_token
    skip_before_action :require_artsy_authentication

    rescue_from RailsParam::Param::InvalidParameterError do |ex|
      error!(ex.message, 400, param: ex.param)
    end

    rescue_from ActiveRecord::RecordNotFound do |_e|
      error!('Not Found', 404)
    end
  end
end
