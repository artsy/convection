module Api
  class BaseController < ApplicationController
    include AuthenticationHelpers

    rescue_from RailsParam::Param::InvalidParameterError do |ex|
      error!(ex.message, 400, param: ex.param)
    end
  end
end
