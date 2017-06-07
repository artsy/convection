# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    include ArtsyAuth::Authenticated

    before_filter :default_params

    private

    def default_params
      params[:order] ||= "created_at"
      params[:direction] ||= "desc"
    end

    def authorized_artsy_token?(token)
      ArtsyAdminAuth.valid?(token)
    end
  end
end
