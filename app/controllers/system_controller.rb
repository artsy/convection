# frozen_string_literal: true

class SystemController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_artsy_authentication

  def up
    render json: { rails: true }, status: :ok
  end
end
