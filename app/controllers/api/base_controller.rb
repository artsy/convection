module Api
  class BaseController < ApplicationController
    include AuthenticationHelpers

    rescue_from RailsParam::Param::InvalidParameterError do |ex|
      error!(ex.message, 400, param: ex.param)
    end

    rescue_from ActiveRecord::RecordNotFound do |_e|
      error!('Not Found', 404)
    end
  end
end
