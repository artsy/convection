module Admin
  class ApplicationController < Administrate::ApplicationController
    include ArtsyAuth::Authenticated

    before_action :default_params

    private

    def default_params
      params[:order] ||= 'created_at'
      params[:direction] ||= 'desc'
    end

    def authorized_artsy_token?(token)
      ArtsyAdminAuth.valid?(token)
    end
  end
end
